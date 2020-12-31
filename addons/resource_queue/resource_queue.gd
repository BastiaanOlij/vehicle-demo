extends Node

# From https://docs.godotengine.org/en/3.1/tutorials/io/background_loading.html#using-multiple-threads
# I guess written by Punto?
# Few small improvements by Mux213

var thread = null
var mutex = null
var sem = null

var time_max = 100 # msec
var running = false # have we started our thread?

var queue = []
var pending = {}

func _lock(caller):
	mutex.lock()

func _unlock(caller):
	mutex.unlock()

func _post(caller):
	sem.post()

func _wait(caller):
	sem.wait()

func queue_resource(path, p_in_front = false):
	_lock("queue_resource")
	if path in pending:
		_unlock("queue_resource")
		return
	
	elif ResourceLoader.has(path):
		var res = ResourceLoader.load(path)
		pending[path] = res
		_unlock("queue_resource")
		return
	else:
		var res = ResourceLoader.load_interactive(path)
		res.set_meta("path", path)
		if p_in_front:
			queue.insert(0, res)
		else:
			queue.push_back(res)
		pending[path] = res
		_post("queue_resource")
		_unlock("queue_resource")
		return

func cancel_resource(path):
	_lock("cancel_resource")
	if path in pending:
		if pending[path] is ResourceInteractiveLoader:
			queue.erase(pending[path])
		pending.erase(path)
	_unlock("cancel_resource")

func get_progress(path):
	_lock("get_progress")
	var ret = -1
	if path in pending:
		if pending[path] is ResourceInteractiveLoader:
			ret = float(pending[path].get_stage()) / float(pending[path].get_stage_count())
		else:
			ret = 1.0
	_unlock("get_progress")
	
	return ret

func is_ready(path):
	var ret
	_lock("is_ready")
	if path in pending:
		ret = !(pending[path] is ResourceInteractiveLoader)
	else:
		ret = false
	
	_unlock("is_ready")
	
	return ret

func _wait_for_resource(res, path):
	_unlock("wait_for_resource")
	while true:
		VisualServer.sync()
		OS.delay_usec(16000) # wait 1 frame
		_lock("wait_for_resource")
		if queue.size() == 0 || queue[0] != res:
			return pending[path]
		_unlock("wait_for_resource")

func get_resource(path):
	_lock("get_resource")
	if path in pending:
		if pending[path] is ResourceInteractiveLoader:
			var res = pending[path]
			if res != queue[0]:
				var pos = queue.find(res)
				queue.remove(pos)
				queue.insert(0, res)
			
			res = _wait_for_resource(res, path)
			
			pending.erase(path)
			_unlock("return")
			return res
		
		else:
			var res = pending[path]
			pending.erase(path)
			_unlock("return")
			return res
	else:
		_unlock("return")
		return ResourceLoader.load(path)

func thread_process():
	_wait("thread_process")
	
	_lock("process")
	
	while queue.size() > 0:
	
		var res = queue[0]
		
		_unlock("process_poll")
		var ret = res.poll()
		_lock("process_check_queue")
		
		if ret == ERR_FILE_EOF || ret != OK:
			var path = res.get_meta("path")
			if path in pending: # else it was already retrieved
				pending[res.get_meta("path")] = res.get_resource()
			
			queue.erase(res) # something might have been put at the front of the queue while we polled, so use erase instead of remove
	
	_unlock("process")


func thread_func(u):
	running = true
	while running:
		thread_process()
	
	# Should we clean up our pending resource loaders?
	# I don't think it matters

func _is_running():
	_lock("is_running")
	
	var res = running
	
	_unlock("is_running")
	
	return res

func start():
	if !mutex:
		mutex = Mutex.new()
	if !sem:
		sem = Semaphore.new()
	if !thread:
		thread = Thread.new()
	
	if !_is_running():
		thread.start(self, "thread_func", 0)

func stop():
	if _is_running():
		# cause our thread loop to exit
		_lock("stop_running")
		running = false
		_unlock("stop_running")
		
		# and wait for our thread to exit cleanly..
		thread.wait_to_finish();

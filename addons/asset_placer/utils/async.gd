extends RefCounted
class_name AssetPlacerAsync

var _job_ids: Array[int] = []

static var _instance: AssetPlacerAsync

static func instance() -> AssetPlacerAsync:
	if not _instance:
		_instance = AssetPlacerAsync.new()

	return _instance


func enqueue(callable: Callable) -> void:
	var id: int = WorkerThreadPool.add_task(callable, false, "Asset Placer Task")
	_job_ids.append(id)

func await_completion() -> void:
	for id in _job_ids:
		WorkerThreadPool.wait_for_task_completion(id)

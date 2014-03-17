package io.axel.pool {
	public class AxPool {
		public var allocated:AxPoolList;
		public var idle:AxPoolList;
		public var objectClass:Class;
		public var initialization:Function;
		
		public function AxPool(objectClass:Class, initialCapacity:int = 0, initialization:Function = null) {
			if (objectClass == null) {
				throw new ArgumentError("Must pass a class to pool");
			} else if (initialCapacity < 0) {
				throw new ArgumentError("Must pass a non-negative initial capacity");
			}
			
			this.objectClass = objectClass;
			this.initialization = initialization;
			
			idle = new AxPoolList;
			allocated = new AxPoolList;
			for (var i:uint = 0; i < initialCapacity; i++) {
				add(new objectClass);
			}
		}
		
		public function remove():* {
			var node:AxPoolNode = allocated.remove();
			var object:* = node.object;
			if (object == null) {
				object = new objectClass;
				if (initialization != null) {
					initialization(object);
				}
			}
			node.object = null;
			idle.add(node);
			return object;
		}
		
		public function add(object:*):void {
			if (object == null) {
				throw new ArgumentError("Cannot add a null object to a pool");
			}
			var node:AxPoolNode = idle.remove();
			node.object = object;
			allocated.add(node);
		}
	}
}

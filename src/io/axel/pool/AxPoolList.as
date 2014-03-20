package io.axel.pool {
	/**
	 * A linked list allowing to for easy pooling of objects.
	 */
	public class AxPoolList {
		public var head:AxPoolNode;
		public var size:uint = 0;
		
		public function AxPoolList(initialCapacity:int = 0) {
			if (initialCapacity < 0) {
				throw new ArgumentError("Must supply non-negative capacity.");
			}
			for (var i:uint = 0; i < initialCapacity; i++) {
				add(new AxPoolNode);
			}
		}
		
		public function remove():AxPoolNode {
			if (head == null) {
				return new AxPoolNode;
			} else {
				var node:AxPoolNode = head;
				head = head.next;
				size--;
				return node;
			}
		}
		
		public function add(node:AxPoolNode):void {
			if (node == null) {
				throw new ArgumentError("Cannot add null node to list");
			}
			node.next = head;
			head = node;
			size++;
		}
	}
}

package io.axel.render {
	public interface ShaderProvider {
		/**
		 * This method must return the vertex shader used for the class. Under normal circumstances,
		 * it should only be called once, for the first object created of the class type, as shaders
		 * are cached on a per-class basis.
		 *
		 * @return This class's vertex shader.
		 */
		function buildVertexShader():Array;
		
		/**
		 * This method must return the fragment shader used for the class. Under normal circumstances,
		 * it should only be called once, for the first object created of the class type, as shaders
		 * are cached on a per-class basis.
		 *
		 * @return This class's fragment shader.
		 */
		function buildFragmentShader():Array;
	}
}

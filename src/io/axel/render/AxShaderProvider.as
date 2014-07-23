package io.axel.render {
	/**
	 * Implementing classes contain logic that allows them to provider both a vertex and fragment
	 * shader.
	 */
	public interface AxShaderProvider {
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

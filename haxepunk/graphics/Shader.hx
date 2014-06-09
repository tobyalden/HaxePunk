package haxepunk.graphics;

import lime.gl.GL;
import lime.gl.GLShader;
import lime.gl.GLProgram;
import lime.gl.GLUniformLocation;

typedef ShaderSource = {
	var src:String;
	var fragment:Bool;
}

/**
 * GLSL Shader object
 */
class Shader
{

	/**
	 * Creates a new Shader
	 * @param sources  A list of glsl shader sources to compile and link into a program
	 */
	public function new(sources:Array<ShaderSource>)
	{
		_program = GL.createProgram();

		for (source in sources)
		{
			var shader = compile(source.src, source.fragment ? GL.FRAGMENT_SHADER : GL.VERTEX_SHADER);
			if (shader == null) return;
			GL.attachShader(_program, shader);
			GL.deleteShader(shader);
		}

		GL.linkProgram(_program);

		if (GL.getProgramParameter(_program, GL.LINK_STATUS) == 0)
		{
			trace(GL.getProgramInfoLog(_program));
			trace("VALIDATE_STATUS: " + GL.getProgramParameter(_program, GL.VALIDATE_STATUS));
			trace("ERROR: " + GL.getError());
			return;
		}
	}

	/**
	 * Compiles the shader source into a GlShader object and prints any errors
	 * @param source  The shader source code
	 * @param type    The type of shader to compile (fragment, vertex)
	 */
	private function compile(source:String, type:Int):GLShader
	{
		var shader = GL.createShader(type);
		GL.shaderSource(shader, source);
		GL.compileShader(shader);

		if (GL.getShaderParameter(shader, GL.COMPILE_STATUS) == 0)
		{
			trace(GL.getShaderInfoLog(shader));
			return null;
		}

		return shader;
	}

	/**
	 * Return the attribute location in this shader
	 * @param a  The attribute name to find
	 */
	public inline function attribute(a:String):Int
	{
		return GL.getAttribLocation(_program, a);
	}

	/**
	 * Return the uniform location in this shader
	 * @param a  The uniform name to find
	 */
	public inline function uniform(u:String):GLUniformLocation
	{
		return GL.getUniformLocation(_program, u);
	}

	/**
	 * Bind the program for rendering
	 */
	public inline function use()
	{
		if (_lastUsedProgram != _program)
		{
			GL.useProgram(_program);
			_lastUsedProgram = _program;
		}
	}

	public static function clear()
	{
		_lastUsedProgram = null;
		GL.useProgram(_lastUsedProgram);
	}

	private var _program:GLProgram;
	private static var _lastUsedProgram:GLProgram;

}
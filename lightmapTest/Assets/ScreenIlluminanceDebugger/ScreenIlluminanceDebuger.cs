using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class ScreenIlluminanceDebuger : MonoBehaviour {

	public enum RGBA
	{
		All = 0,
		R = 1,
		G = 2,
		B = 3,
		A = 4
	};
	// shader and material for rendering.
	public Shader shader;
	private Material m_mat;

	// debug color.
	public Color debugColor = Color.red;

	// Value threshold for debugging, the pixel will display debugColor if the channel value is greater than valueThreshold.
	public float valueThreshold = 0.1f;

	// the channel to debug.
	public RGBA debugChannel = RGBA.All;

	// debug switch.
	public bool showDebugColor = true;

	// output channel switch.
	public RGBA outputChannelSwitch = RGBA.All;


	// Use this for initialization
	void Start () {
		if (shader == null || shader.name != "Hidden/ScreenIlluminanceDebuger") {
			shader = Shader.Find ("Hidden/ScreenIlluminanceDebuger");
		}

		if (shader != null && shader.isSupported) {
			m_mat = new Material (shader);
		} else {
			Debug.LogWarning (this.name + " is not working correctly or not supportted.");
			this.enabled = false;
		}
	}

	public void SetParams(){
		m_mat.SetColor ("debugColor",debugColor);
		m_mat.SetFloat ("luma", valueThreshold);
		m_mat.SetInt ("rgbaFlag",(int)debugChannel);
		m_mat.SetInt ("dispRGBA",(int)outputChannelSwitch);
		m_mat.SetInt ("isDebug",showDebugColor == false?0:1);
	}
	
	// Update is called once per frame
	void OnRenderImage(RenderTexture src,RenderTexture dest) {

		SetParams ();

		if (m_mat != null) {
			Graphics.Blit (src, dest, m_mat, 0);
		}
	}
}

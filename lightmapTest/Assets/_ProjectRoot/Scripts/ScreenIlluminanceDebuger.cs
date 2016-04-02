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
	// shader for rendering.
	public Shader shader;
	private Material m_mat;
	public Color debugColor = Color.red;
	public float illuminanceThreshold = 1.0f;
	public RGBA debugChannel = RGBA.All;
	public bool showDebugColor = true;
	public RGBA displayChannel = RGBA.All;


	// Use this for initialization
	void Start () {
		if (shader == null || shader.name != "Hidden/ScreenIlluminanceDebuger") {
			shader = Shader.Find ("Hidden/ScreenIlluminanceDebuger");
		}

		if (shader != null && shader.isSupported) {
			m_mat = new Material(shader);
		}
	}

	public void SetParams(){
		m_mat.SetColor ("debugColor",debugColor);
		m_mat.SetFloat ("luma", illuminanceThreshold);
		m_mat.SetInt ("rgbaFlag",(int)debugChannel);
		m_mat.SetInt ("dispRGBA",(int)displayChannel);
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

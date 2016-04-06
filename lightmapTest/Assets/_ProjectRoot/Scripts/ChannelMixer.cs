using UnityEngine;
using UnityEditor;
using System.IO;
using System.Collections;

/// <summary>
/// Channel mixer.
/// ZiZi 2014
/// </summary>
public class ChannelMixer : EditorWindow {
	//	Channel Enum
	public enum TextureChannel{
		R,	G,	B,	A
	};

	//	Texture src enum
	public enum UseTexture{
		Input1,	Input2,	Input3,	Input4,	White,	Black
	};

	//	Texture src
	private Texture2D tex1;
	private Texture2D tex2;
	private Texture2D tex3;
	private Texture2D tex4;

	//	Show Input info?	
	private bool m_IsShowInoutInfo = false;

	//	Input usage -->
	private UseTexture 		m_texUseR;
	private TextureChannel 	m_chnUseR;
	private bool 			isReadableAtFirst_R = false;

	private UseTexture 		m_texUseG;
	private TextureChannel 	m_chnUseG;
	private bool 			isReadableAtFirst_G = false;

	private UseTexture 		m_texUseB;
	private TextureChannel 	m_chnUseB;
	private bool 			isReadableAtFirst_B = false;

	private UseTexture 		m_texUseA = UseTexture.White;
	private TextureChannel 	m_chnUseA;
	private bool 			isReadableAtFirst_A = false;
	//	End Input usage <--

	//	Output settings -->
	private int[] 			ANISOLEVELSET = {0,1,2,3,4,5,6,7,8,9};
	private string[] 		ANISOLEVELSTR = {"0","1","2","3","4","5","6","7","8","9"};
	private string			m_name = "Output";
	private string 			m_path;
	private Texture2D 		m_output;
	private Vector2 		m_size = new Vector2(512,512);
	private TextureFormat 	m_format = TextureFormat.ARGB32;
	private TextureWrapMode m_wrap = TextureWrapMode.Clamp;
	private FilterMode 		m_filter = FilterMode.Bilinear;
	private int				m_anisoLevel = 9;
	//	End output setting <--

	private Texture2D 		m__whiteMap;
	private Texture2D 		m__BlackMap;
	
	[MenuItem ("Tools/ChannelMixer")]
	public static void  ShowWindow () {
		EditorWindow.GetWindowWithRect(typeof(ChannelMixer), new Rect(100,100,400,600));
		//EditorWindow.GetWindow(typeof(ChannelMixer));
	}
	
	void OnGUI () {
		ChannelMixerBaseGUI();
	}

	protected void ChannelMixerBaseGUI(){
		// Input -->
		GUILayout.Label("Input 1:",EditorStyles.boldLabel);
		tex1 = (Texture2D) EditorGUILayout.ObjectField(tex1,typeof(Texture2D),true);
		if(m_IsShowInoutInfo && tex1){
			GUIdisplayTexInfo(ref tex1);
		}
		GUILayout.Label("Input 2:",EditorStyles.boldLabel);
		tex2 = (Texture2D) EditorGUILayout.ObjectField(tex2,typeof(Texture2D),true);
		if(m_IsShowInoutInfo && tex2){
			GUIdisplayTexInfo(ref tex2);
		}
		GUILayout.Label("Input 3:",EditorStyles.boldLabel);
		tex3 = (Texture2D) EditorGUILayout.ObjectField(tex3,typeof(Texture2D),true);
		if(m_IsShowInoutInfo && tex3){
			GUIdisplayTexInfo(ref tex3);
		}
		
		GUILayout.Label("Input 4:",EditorStyles.boldLabel);
		tex4 = (Texture2D) EditorGUILayout.ObjectField(tex4,typeof(Texture2D),true);
		if(m_IsShowInoutInfo && tex4){
			GUIdisplayTexInfo(ref tex4);
		}
		// End Input <--

		// Show Info toggle
		GUILayout.Space(10);
		m_IsShowInoutInfo =  GUILayout.Toggle(m_IsShowInoutInfo,"Show Input Info.");


		EditorGUILayout.BeginHorizontal();

		EditorGUILayout.BeginVertical();
		// Output setting -->
		GUILayout.Space(10);
		GUILayout.Label("\nOutput:",EditorStyles.boldLabel);
		GUILayout.Label("Output Name: ",EditorStyles.label);
		m_name = GUILayout.TextField(m_name,64);

		GUILayout.Space(10);
		GUILayout.Label("Chanel(R) from: ",EditorStyles.label);
		EditorGUILayout.BeginHorizontal();
		m_texUseR = (UseTexture)EditorGUILayout.EnumPopup(m_texUseR);
		m_chnUseR = (TextureChannel)EditorGUILayout.EnumPopup(m_chnUseR);
		EditorGUILayout.EndHorizontal();
		
		GUILayout.Label("Chanel(G) from: ",EditorStyles.label);
		EditorGUILayout.BeginHorizontal();
		m_texUseG = (UseTexture)EditorGUILayout.EnumPopup(m_texUseG);
		m_chnUseG = (TextureChannel)EditorGUILayout.EnumPopup(m_chnUseG);
		EditorGUILayout.EndHorizontal();
		
		GUILayout.Label("Chanel(B) from: ",EditorStyles.label);
		EditorGUILayout.BeginHorizontal();
		m_texUseB = (UseTexture)EditorGUILayout.EnumPopup(m_texUseB);
		m_chnUseB = (TextureChannel)EditorGUILayout.EnumPopup(m_chnUseB);
		EditorGUILayout.EndHorizontal();
		
		GUILayout.Label("Chanel(A) from: ",EditorStyles.label);
		EditorGUILayout.BeginHorizontal();
		m_texUseA = (UseTexture)EditorGUILayout.EnumPopup(m_texUseA);
		m_chnUseA = (TextureChannel)EditorGUILayout.EnumPopup(m_chnUseA);
		EditorGUILayout.EndHorizontal();

		EditorGUILayout.EndVertical();
		
		EditorGUILayout.BeginVertical();

		GUILayout.Space(45);
		m_size = EditorGUILayout.Vector2Field("Resolution:",m_size);
		EditorGUILayout.BeginHorizontal();
		if(GUILayout.Button("256")){
			m_size.x = 256; m_size.y = 256;
		}
		if(GUILayout.Button("512")){
			m_size.x = 512; m_size.y = 512;
		}
		if(GUILayout.Button("1024")){
			m_size.x = 1024; m_size.y = 1024;
		}
		if(GUILayout.Button("2048")){
			m_size.x = 2048; m_size.y = 2048;
		}
		if(GUILayout.Button("4096")){
			m_size.x = 4096; m_size.y = 4096;
		}
		EditorGUILayout.EndHorizontal();

		GUILayout.Space(10);
		m_wrap = (TextureWrapMode)EditorGUILayout.EnumPopup("Wrap Mode:",m_wrap);
		m_filter = (FilterMode)EditorGUILayout.EnumPopup("Filter Mode:",m_filter);
		m_format = (TextureFormat)EditorGUILayout.EnumPopup("Format:",m_format);
		m_anisoLevel = EditorGUILayout.IntPopup("AnisoLevel:", m_anisoLevel,ANISOLEVELSTR,ANISOLEVELSET);
		// End output setting <--

		// Create Texture -->
		GUILayout.Space(5);
		GUI.color = Color.green;
		if(GUILayout.Button("Generate Texture",GUILayout.Height(40))){
			// Create Texture
			//	TODO: abstract Generation process into class;
			bool IsCreateSuccessful = GenerateTexture();

			string msg,title;
			msg = IsCreateSuccessful ? 
					"Texture has been successfully created.\n See the output in Result Slot.":
					"An error occured when generating. \nSee console for details." ;
			title = IsCreateSuccessful ? 
					"Done":
					"Creating Texture FAILED!" ;

			EditorUtility.DisplayDialog(title, msg, "OK");
		}
		GUI.color = Color.white;
		// End create <--
		EditorGUILayout.EndVertical();
		
		EditorGUILayout.EndHorizontal();
		// Result -->
		GUILayout.Label("\nResult:",EditorStyles.boldLabel);
		m_output = (Texture2D) EditorGUILayout.ObjectField(m_output,typeof(Texture2D),true);

		if(m_output){
			GUILayout.Space(10);
			if(GUILayout.Button("Save result as PNG file",GUILayout.Height(50))){

				//	TODO: abstract save method into class.
				SaveToPNG();
			}
		}
		// End Result <--

		GUILayout.Label("\n\n\t\t\t\t\t\t\t\t\t\tZiZi 2014",EditorStyles.boldLabel);
	}

	protected void SaveToPNG(){
		if( m_name.Length > 0 ){

			m_path =  EditorUtility.SaveFilePanelInProject("Save Result", 
			                                               m_name + ".png",
			                                               "png","Save!");
			if(m_path.Length <= 0)return;
			byte[] pngByte = m_output.EncodeToPNG();
			File.WriteAllBytes(m_path, pngByte);
				
			AssetDatabase.ImportAsset(m_path);
			try{
			TextureImporter ti = (TextureImporter)TextureImporter.GetAtPath(m_path);
			ti.maxTextureSize = (int)Mathf.Max(m_size.x, m_size.y);
			ti.wrapMode = m_wrap;
			ti.anisoLevel = m_anisoLevel;
			ti.name = m_name;
			ti.filterMode = m_filter;
			AssetDatabase.ImportAsset(m_path);
			}catch(UnityException e){
				EditorUtility.DisplayDialog("Save PNG file FAILED!",
				                            "See console for more details.",
				                            "OK");
				Debug.LogError(e.Message);
			}

			AssetDatabase.Refresh();
			EditorUtility.DisplayDialog("Done!",
			                            "PNG saved.\n" + m_path,
			                            "OK");
		}
			
		else if(m_name.Length <= 0){
			EditorUtility.DisplayDialog("Invalid file name",
			                            "Check the name in Output Name slot.",
			                            "OK");
		}
	}

	/// <summary>
	/// Display texture Info
	/// </summary>
	/// <param name="tex">Tex.</param>
	protected void GUIdisplayTexInfo(ref Texture2D tex){
		//GUILayout.Label("Name: " + tex.name,EditorStyles.label);
		//EditorGUILayout.BeginToggleGroup("Info",false);
		GUI.color = Color.grey;
		GUILayout.Label("\tSize: " + tex.width + " x " + tex.height,EditorStyles.label);
		GUILayout.Label("\tTextureType: " + tex.format.ToString(),EditorStyles.label);
		GUILayout.Label("\tAnisoLevel: " + tex.anisoLevel,EditorStyles.label);
		GUILayout.Label("\tMipMapCount: " + tex.mipmapCount,EditorStyles.label);
		GUI.color = Color.white;
		//EditorGUILayout.EndToggleGroup();
	}

	/// <summary>
	/// Generates the texture.
	/// </summary>
	/// <returns><c>true</c>, if texture was generated, <c>false</c> otherwise.</returns>
	private bool GenerateTexture(){

		Texture2D srcR,srcG,srcB,srcA;

		if(!m__whiteMap){
			m__whiteMap = new Texture2D(1,1);
			m__whiteMap.SetPixel(0,0,Color.white);
		}
		
		if(!m__BlackMap){
			m__BlackMap = new Texture2D(1,1);
			m__BlackMap.SetPixel(0,0,Color.black);
		}

		if(m_size.x <= 0 ||m_size.y <= 0){
			Debug.LogError("Resolution must greater than zero! Generation aborted.");
			return false;
		}

		#region SET_INPUT
		SetChannelSrc(out srcR, ref m_texUseR);
		SetChannelSrc(out srcG, ref m_texUseG);
		SetChannelSrc(out srcB, ref m_texUseB);
		SetChannelSrc(out srcA, ref m_texUseA);

		if(!srcR){
			Debug.LogWarning("The Input of Output Channel(R) is empty! Generation aborted.");
			return false;
		}

		if(!srcG){
			Debug.LogWarning("The Input of Output Channel(G) is empty! Generation aborted.");
			return false;
		}

		if(!srcB){
			Debug.LogWarning("The Input of Output Channel(B) is empty! Generation aborted.");
			return false;
		}

		if(!srcA){
			Debug.LogWarning("The Input of Output Channel(A) is empty! Generation aborted.");
			return false;
		}

		isReadableAtFirst_R = IsTextureReadable(ref srcR);
		isReadableAtFirst_G = IsTextureReadable(ref srcG);
		isReadableAtFirst_B = IsTextureReadable(ref srcB);
		isReadableAtFirst_A = IsTextureReadable(ref srcA);
		#endregion

		// Create texture -->
		Color c;
		Vector2 uv;
		m_output = new Texture2D(Mathf.FloorToInt(m_size.x),Mathf.FloorToInt(m_size.y));

		// Set all texture to readable
		if(!isReadableAtFirst_R)SetTextureReadable(ref srcR,true);
		if(!isReadableAtFirst_G)SetTextureReadable(ref srcG,true);
		if(!isReadableAtFirst_B)SetTextureReadable(ref srcB,true);
		if(!isReadableAtFirst_A)SetTextureReadable(ref srcA,true);

		for(int y = 0; y < m_output.height; ++y){
			for(int x = 0; x < m_output.width; ++x){

				uv.x = (float)x / (float)m_output.width;
				uv.y = (float)y / (float)m_output.height;

				try{
					c.r = GetChannelValue(ref srcR, uv.x, uv.y, m_chnUseR);
					c.g = GetChannelValue(ref srcG, uv.x, uv.y, m_chnUseG);
					c.b = GetChannelValue(ref srcB, uv.x, uv.y, m_chnUseB);
					c.a = GetChannelValue(ref srcA, uv.x, uv.y, m_chnUseA);

				}catch(UnityException e){
					SetTextureReadable(ref srcR,isReadableAtFirst_R);
					SetTextureReadable(ref srcG,isReadableAtFirst_G);
					SetTextureReadable(ref srcB,isReadableAtFirst_B);
					SetTextureReadable(ref srcA,isReadableAtFirst_A);
					Debug.LogError(e.Message);
					return false;
				}

				m_output.SetPixel(x,y,c);
			}
		}

		m_output.name = m_name;
		m_output.wrapMode = m_wrap;
		m_output.filterMode = m_filter;
		m_output.anisoLevel = m_anisoLevel;

		m_output.Apply();
		// End Creating <--

		SetTextureReadable(ref srcR,isReadableAtFirst_R);
		SetTextureReadable(ref srcG,isReadableAtFirst_G);
		SetTextureReadable(ref srcB,isReadableAtFirst_B);
		SetTextureReadable(ref srcA,isReadableAtFirst_A);
		return true;
	}

	private void SetChannelSrc(out Texture2D src, ref UseTexture useEnum){
		switch(useEnum){
		case UseTexture.Input1: src = tex1;break;
		case UseTexture.Input2: src = tex2;break;
		case UseTexture.Input3: src = tex3;break;
		case UseTexture.Input4: src = tex4;break;
		case UseTexture.White:  src = m__whiteMap;break;
		case UseTexture.Black:  src = m__BlackMap;break;
		default: src = EditorGUIUtility.whiteTexture;break;
		}
	}

	/// <summary>
	/// Gets the channel value from src and given uv.
	/// </summary>
	/// <returns>The channel value.</returns>
	/// <param name="src">Source.</param>
	/// <param name="u">U.</param>
	/// <param name="v">V.</param>
	/// <param name="channel">Channel.</param>
	static protected float GetChannelValue(ref Texture2D src, float u, float v, TextureChannel channel){
		if(!src){
			throw new UnityException("Input texture is not available! Please check.");
		}

		else{
			switch(channel){
			case TextureChannel.R:
				return src.GetPixelBilinear(u, v).r;
						//break;
			case TextureChannel.G:
				return src.GetPixelBilinear(u, v).g;
						//break;
			case TextureChannel.B:
				return src.GetPixelBilinear(u, v).b;
						//break;
			case TextureChannel.A:
				return src.GetPixelBilinear(u, v).a;
						//break;
			default:
				return 0;
						//break;
			}
		}
	}

	/// <summary>
	/// Determines whether this texture is readable.
	/// </summary>
	/// <returns><c>true</c> if this instance is texture readable the specified texture; otherwise, <c>false</c>.</returns>
	/// <param name="texture">Texture.</param>
	static public bool IsTextureReadable(ref Texture2D texture){
		if(!texture){return false;}

		string path = AssetDatabase.GetAssetPath(texture);
		if(path.Length > 0){
			TextureImporter ti = (TextureImporter)TextureImporter.GetAtPath(path);
			return ti.isReadable;}

		else{
			return false;
		}
	}

	/// <summary>
	/// Sets the texture readable.
	/// </summary>
	/// <param name="texture">Texture.</param>
	/// <param name="isReadable">If set to <c>true</c> is readable.</param>
	static public void SetTextureReadable(ref Texture2D texture, bool isReadable){
		if(!texture){return;}
		
		string path = AssetDatabase.GetAssetPath(texture);

		if(path.Length > 0 ){
			TextureImporter ti = (TextureImporter)TextureImporter.GetAtPath(path);
			ti.isReadable = isReadable;
			AssetDatabase.ImportAsset(path);
		}
	}

}

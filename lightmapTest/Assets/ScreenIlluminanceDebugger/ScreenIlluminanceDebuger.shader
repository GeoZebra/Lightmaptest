Shader "Hidden/ScreenIlluminanceDebuger"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always


		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			float4 debugColor;
			float luma;

			// 0 = all channel; 1 = R, 2 = B, 3 = B, 4 = A	
			int rgbaFlag;
			int dispRGBA;
			int isDebug;

			fixed4 frag (v2f i) : SV_Target
			{
				float4 screenColor = tex2D(_MainTex, i.uv);

				if(isDebug == 1){
					switch(rgbaFlag){
						case 0:
							if(Luminance(screenColor.rgb) > luma){
								return debugColor;
							}
							break;
						case 1:
							if(screenColor.r > luma){
								return debugColor;
							}
							break;
						case 2:
							if(screenColor.g > luma){
								return debugColor;
							}
							break;
						case 3:
							if(screenColor.b > luma){
								return debugColor;
							}
							break;
						case 4:
							if(screenColor.r > luma){
								return debugColor;
							}
						break;
					}
				}

				switch(dispRGBA){
					case 0:
						return screenColor;
						break;
					case 1:
						return screenColor.r;
						break;
					case 2:
						return screenColor.g;
						break;
					case 3:
						return screenColor.b;
						break;
					case 4:
						return screenColor.a;
						break;
					break;
				}

				return screenColor;
			}
			ENDCG
		}
	}
}

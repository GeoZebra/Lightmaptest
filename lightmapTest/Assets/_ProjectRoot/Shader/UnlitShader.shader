Shader "Unlit/NewUnlitShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		uv01("uv channel",float) = 0
		_col("Color", Color) = (1,1,1,1)
		//hdrCoef("HDR float",vector) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				UNITY_FOG_COORDS(2)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float uv01;

			float4 _col;
			#define hdrCoef  float4(40,2.2,0,0)
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.uv1, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			float4 frag (v2f i) : SV_Target
			{
				// sample the texture

				float2 uv = uv01 == 0? i.uv.xy : i.uv.zw;
				fixed4 col = tex2D(_MainTex, uv);

				float4 hdrColor =1;

				hdrColor.rgb = DecodeLightmapRGBM( col, hdrCoef );
				// apply fog
				//UNITY_APPLY_FOG(i.fogCoord, col);

				//col.xyz = col.xyz * col.a * 5;
				return hdrColor * _col;
				//return col;
			}
			ENDCG
		}
	}
}

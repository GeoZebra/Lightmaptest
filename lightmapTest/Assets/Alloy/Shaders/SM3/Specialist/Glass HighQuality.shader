// Alloy Physical Shader Framework
// Copyright 2013-2015 RUST LLC.
// http://www.alloy.rustltd.com/

Shader "Alloy/Glass/HighQuality" {
Properties {
	_Lightmapping ("'GI' {LightmapEmissionProperty:{}}", Float) = 1
	
	// Main Textures
	_MainTextures ("'Main Textures' {Section:{126, 41, 41}}", Float) = 0
	[LM_Albedo] [LM_Transparency] 
	_Color ("'Tint' {}", Color) = (1,1,1,1)	
	[LM_MasterTilingOffset] [LM_Albedo] 
	_MainTex ("'Base Color(RGB) Opacity(A)' {Visualize:{RGB, A}}", 2D) = "white" {}
	_MainTexVelocity ("Scroll", Vector) = (0,0,0,0) 
	_MainTexUV ("UV Set", Float) = 0
	[LM_Metallic]
 	_SpecTex ("'Metal(R) AO(G) Spec(B) Rough(A)' {Visualize:{R, G, B, A}, Parent:_MainTex}", 2D) = "white" {}
	[LM_NormalMap]
	_BumpMap ("'Normals' {Visualize:{NRM}, Parent:_MainTex}", 2D) = "bump" {}
	_BaseColorVertexTint ("'Vertex Color Tint' {Min:0, Max:1}", Float) = 0
	 
	// Main Physical Properties
	_MainPhysicalProperties ("'Main Physical Properties' {Section:{126, 66, 41}}", Float) = 0
	[LM_Metallic]
	_Metal ("'Metallic' {Min:0, Max:1}", Float) = 1
	_Specularity ("'Specularity' {Min:0, Max:1}", Float) = 1
	_Roughness ("'Roughness' {Min:0, Max:1}", Float) = 1
	_Occlusion ("'Occlusion Strength' {Min:0, Max:1}", Float) = 1
	_BumpScale ("'Normal Strength' {}", Float) = 1
		
	// Distortion Properties 
	_DistortionProperties ("'Distortion Properties' {Section:{126, 92, 41}}", Float) = 0
	_DistortWeight ("'Weight' {Min:0, Max:1}", Float) = 1
	_DistortIntensity ("'Intensity' {Min:0, Max:128}", Float) = 10
	_DistortGeoWeight ("'Geometry Influence' {Min:0, Max:1}", Float) = 1

	// Parallax Properties
	[Toggle(_PARALLAX_ON)]
	_ParallaxT ("'Parallax Properties' {Feature:{109, 126, 41}}", Float) = 0
	[KeywordEnum(Parallax, POM)]
	_BumpMode ("'Mode' {Dropdown:{Parallax:{_MinSamples, _MaxSamples}, POM:{}}}", Float) = 0
	_ParallaxMap ("'Heightmap(G)' {Visualize:{G}, Parent:_MainTex}", 2D) = "black" {}
	_Parallax ("'Height' {Min:0, Max:0.08}", Float) = 0.02
	_MinSamples ("'Min Samples' {Min:1}", Float) = 4
	_MaxSamples ("'Max Samples' {Min:1}", Float) = 20
	
	// AO2 Properties
	[Toggle(_AO2_ON)] 
	_AO2 ("'AO2 Properties' {Feature:{83, 126, 41}}", Float) = 0
	_Ao2Map ("'AO2(G)' {Visualize:{RGB}}", 2D) = "white" {} 
	_Ao2MapUV ("UV Set", Float) = 1
	_Ao2Occlusion ("'Occlusion Strength' {Min:0, Max:1}", Float) = 1
	
	// Detail Properties
	[Toggle(_DETAIL_ON)] 
	_DetailT ("'Detail Properties' {Feature:{57, 126, 41}}", Float) = 0
	[Enum(Mul, 0, MulX2, 1)] 
	_DetailMode ("'Mode' {Dropdown:{Mul:{}, MulX2:{}}}", Float) = 0
	_DetailMask ("'Mask(A)' {Visualize:{A}, Parent:_MainTex}", 2D) = "white" {}
	_DetailWeight ("'Weight' {Min:0, Max:1}", Float) = 1
	_DetailAlbedoMap ("'Color' {Visualize:{RGB}}", 2D) = "white" {}
	_DetailAlbedoMapVelocity ("Scroll", Vector) = (0,0,0,0) 
	_DetailAlbedoMapUV ("UV Set", Float) = 0
	_DetailMaterialMap ("'AO(G) Variance(A)' {Visualize:{G, A}, Parent:_DetailAlbedoMap}", 2D) = "white" {}
	_DetailNormalMap ("'Normals' {Visualize:{NRM}, Parent:_DetailAlbedoMap}", 2D) = "bump" {}
	_DetailOcclusion ("'Occlusion Strength' {Min:0, Max:1}", Float) = 1
	_DetailNormalMapScale ("'Normal Strength' {}", Float) = 1
	
	// Team Color Properties
	[Toggle(_TEAMCOLOR_ON)] 
	_TeamColor ("'Team Color Properties' {Feature:{41, 126, 50}}", Float) = 0
	[Enum(RGB, 0, RGBA, 1)] 
	_TeamColorMode ("'Mode' {Dropdown:{RGB:{_TeamColor3}, RGBA:{}}}", Float) = 1	
	_TeamColor0 ("'Tint R' {}", Color) = (1,1,1)
	_TeamColor1 ("'Tint G' {}", Color) = (1,1,1)
	_TeamColor2 ("'Tint B' {}", Color) = (1,1,1)
	_TeamColor3 ("'Tint A' {}", Color) = (1,1,1)
	_TeamColorMaskMap ("'Masks' {Visualize:{R, G, B, A}, Parent:_MainTex}", 2D) = "white" {}
	
	// Decal Properties 
	[Toggle(_DECAL_ON)] 
	_Decal ("'Decal Properties' {Feature:{41, 126, 75}}", Float) = 0	
	_DecalColor ("'Tint' {}", Color) = (1,1,1,1)
	_DecalTex ("'Base Color(RGB) Opacity(A)' {Visualize:{RGB, A}}", 2D) = "black" {} 
	_DecalTexUV ("UV Set", Float) = 0
	_DecalWeight ("'Weight' {Min:0, Max:1}", Float) = 1
	_DecalSpecularity ("'Specularity' {Min:0, Max:1}", Float) = 0.5
	_DecalAlphaVertexTint ("'Vertex Alpha Tint' {Min:0, Max:1}", Float) = 0

	// Emission Properties 
	[Toggle(_EMISSION)] 
	_Emission ("'Emission Properties' {Feature:{41, 126, 101}}", Float) = 0
	[LM_Emission] 
	[HDR]
	_EmissionColor ("'Tint' {}", Color) = (1,1,1)
	[LM_Emission] 
	_EmissionMap ("'Color' {Visualize:{RGB}, Parent:_MainTex}", 2D) = "white" {}
	_IncandescenceMap ("'Effect' {Visualize:{RGB}}", 2D) = "white" {} 
	_IncandescenceMapVelocity ("Scroll", Vector) = (0,0,0,0) 
	_IncandescenceMapUV ("UV Set", Float) = 0
	[Gamma]
	_EmissionWeight ("'Weight' {Min:0, Max:1}", Float) = 1

	// Rim Emission Properties 
	[Toggle(_RIM_ON)] 
	_Rim ("'Rim Emission Properties' {Feature:{41, 125, 126}}", Float) = 0
	[HDR]
	_RimColor ("'Tint' {}", Color) = (1,1,1)
	_RimTex ("'Effect' {Visualize:{RGB}}", 2D) = "white" {}
	_RimTexVelocity ("Scroll", Vector) = (0,0,0,0) 
	_RimTexUV ("UV Set", Float) = 0
	[Gamma]
	_RimWeight ("'Weight' {Min:0, Max:1}", Float) = 1
	[Gamma]
	_RimBias ("'Fill' {Min:0, Max:1}", Float) = 0
	_RimPower ("'Falloff' {Min:0.01}", Float) = 4

	// Dissolve Properties 
	[Toggle(_DISSOLVE_ON)] 
	_Dissolve ("'Dissolve Properties' {Feature:{41, 100, 126}}", Float) = 0
	[HDR]
	_DissolveGlowColor ("'Glow Tint' {}", Color) = (1,1,1,1)
	_DissolveTex ("'Glow Color(RGB) Trans(A)' {Visualize:{RGB, A}}", 2D) = "white" {} 
	_DissolveTexUV ("UV Set", Float) = 0
	_DissolveCutoff ("'Cutoff' {Min:0, Max:1}", Float) = 0
	[Gamma]
	_DissolveGlowWeight ("'Glow Weight' {Min:0, Max:1}", Float) = 1
	_DissolveEdgeWidth ("'Glow Width' {Min:0, Max:1}", Float) = 0.01
}

CGINCLUDE
	#define _ALPHAPREMULTIPLY_ON
ENDCG

SubShader {    
	// We must be transparent, so other objects are drawn before this one.
	Tags {
        "Queue"="Transparent" 
        "IgnoreProjector"="True" 
        "RenderType"="Transparent"
    }
    LOD 500

	GrabPass { }
	 
	Pass {
		Name "BASE"
		Tags { "LightMode" = "Always" }
					
		CGPROGRAM	
		#pragma target 3.0
		#pragma exclude_renderers gles
		
		#pragma shader_feature _PARALLAX_ON
		#pragma shader_feature _BUMPMODE_POM
		#pragma shader_feature _DETAIL_ON
		#pragma shader_feature _TEAMCOLOR_ON
		#pragma shader_feature _DECAL_ON
		#pragma shader_feature _DISSOLVE_ON
		
		#pragma vertex AlloyVertexDistort
		#pragma fragment AlloyFragmentDistort
				
		#include "Assets/Alloy/Shaders/Definitions/Core.cginc"
		#include "Assets/Alloy/Shaders/Passes/Distort.cginc"
		ENDCG
	}

	Pass {
		Name "FORWARD" 
		Tags { "LightMode" = "ForwardBase" }

		Blend One OneMinusSrcAlpha
		ZWrite Off

		CGPROGRAM
		#pragma target 3.0
		#pragma exclude_renderers gles
		
		#pragma shader_feature _PARALLAX_ON
		#pragma shader_feature _BUMPMODE_POM
		#pragma shader_feature _AO2_ON
		#pragma shader_feature _DETAIL_ON
		#pragma shader_feature _TEAMCOLOR_ON
		#pragma shader_feature _DECAL_ON
		#pragma shader_feature _EMISSION
		#pragma shader_feature _RIM_ON
		#pragma shader_feature _DISSOLVE_ON
		
		#pragma multi_compile_fwdbase
		#pragma multi_compile_fog
			
		#pragma vertex AlloyVertexForwardBase
		#pragma fragment AlloyFragmentForwardBase
		
		#define UNITY_PASS_FORWARDBASE
		
		#include "Assets/Alloy/Shaders/Definitions/Core.cginc"
		#include "Assets/Alloy/Shaders/Passes/Forward.cginc"

		ENDCG
	}
	
	Pass {
		Name "FORWARD_DELTA"
		Tags { "LightMode" = "ForwardAdd" }
		
		Blend One One
		ZWrite Off

		CGPROGRAM
		#pragma target 3.0
		#pragma exclude_renderers gles
		
		#pragma shader_feature _PARALLAX_ON
		#pragma shader_feature _BUMPMODE_POM 
		#pragma shader_feature _AO2_ON
		#pragma shader_feature _DETAIL_ON
		#pragma shader_feature _TEAMCOLOR_ON
		#pragma shader_feature _DECAL_ON
		#pragma shader_feature _DISSOLVE_ON
		
		#pragma multi_compile_fwdadd_fullshadows
		#pragma multi_compile_fog
		
		#pragma vertex AlloyVertexForwardAdd
		#pragma fragment AlloyFragmentForwardAdd

		#define UNITY_PASS_FORWARDADD

		#include "Assets/Alloy/Shaders/Definitions/Core.cginc"
		#include "Assets/Alloy/Shaders/Passes/Forward.cginc"

		ENDCG
	}
	
	Pass {
		Name "SHADOWCASTER"
		Tags { "LightMode" = "ShadowCaster" }
		
		CGPROGRAM
		#pragma target 3.0
		#pragma exclude_renderers gles

		#pragma shader_feature _DISSOLVE_ON
		
		#pragma multi_compile_shadowcaster

		#pragma vertex AlloyVertexShadowCaster
		#pragma fragment AlloyFragmentShadowCaster
		
		#define UNITY_PASS_SHADOWCASTER
		
		#include "Assets/Alloy/Shaders/Definitions/Core.cginc"
		#include "Assets/Alloy/Shaders/Passes/Shadow.cginc"

		ENDCG
	}
	
	Pass {
		Name "Meta"
		Tags { "LightMode" = "Meta" }
		Cull Off

		CGPROGRAM
		#pragma target 3.0
		#pragma exclude_renderers nomrt gles
		
		#pragma shader_feature _DETAIL_ON
		#pragma shader_feature _TEAMCOLOR_ON
		#pragma shader_feature _DECAL_ON
		#pragma shader_feature _EMISSION
		#pragma shader_feature _RIM_ON
		#pragma shader_feature _DISSOLVE_ON
				
		#pragma vertex AlloyVertexMeta
		#pragma fragment AlloyFragmentMeta
		
		#define UNITY_PASS_META
		
		#include "Assets/Alloy/Shaders/Definitions/Core.cginc"
		#include "Assets/Alloy/Shaders/Passes/Meta.cginc"

		ENDCG
	}
}

FallBack "VertexLit"
CustomEditor "AlloyFieldBasedEditor"
}

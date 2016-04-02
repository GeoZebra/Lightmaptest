// Alloy Physical Shader Framework
// Copyright 2013-2015 RUST LLC.
// http://www.alloy.rustltd.com/

Shader "Alloy/Eye/Eyeball" {
Properties {
	_Lightmapping ("'GI' {LightmapEmissionProperty:{}}", Float) = 1
	
	// Main Textures
	_MainTextures ("'Main Textures' {Section:{126, 41, 41}}", Float) = 0
	[LM_Albedo] [LM_Transparency] 
	_Color ("'Tint' {}", Color) = (1,1,1,1)	
	[LM_MasterTilingOffset] [LM_Albedo] 
	_MainTex ("'Base Color(RGB) Iris Depth(A)' {Visualize:{RGB, A}}", 2D) = "white" {}
	_MainTexVelocity ("Scroll", Vector) = (0,0,0,0) 
	_MainTexUV ("UV Set", Float) = 0
	[LM_Metallic]
 	_SpecTex ("'Iris(R) AO(G) Spec(B) Rough(A)' {Visualize:{R, G, B, A}, Parent:_MainTex}", 2D) = "white" {}
	[LM_NormalMap]
	_BumpMap ("'Normals' {Visualize:{NRM}, Parent:_MainTex}", 2D) = "bump" {}
	_BaseColorVertexTint ("'Vertex Color Tint' {Min:0, Max:1}", Float) = 0
	 
	// Main Physical Properties
	_MainPhysicalProperties ("'Main Physical Properties' {Section:{126, 66, 41}}", Float) = 0
	_Specularity ("'Specularity' {Min:0, Max:1}", Float) = 1
	_Roughness ("'Roughness' {Min:0, Max:1}", Float) = 1
	_Occlusion ("'Occlusion Strength' {Min:0, Max:1}", Float) = 1
	_BumpScale ("'Normal Strength' {}", Float) = 1
	
	// Eye Properties 
	_EyeProperties ("'Eye Properties' {Section:{126, 92, 41}}", Float) = 0
	_EyeSchleraColor ("'Sclera Tint' {}", Color) = (1,1,1)
	_EyeScleraScattering ("'Sclera Scattering' {Min:0, Max:1}", Float) = 0
	_EyeSpecularity ("'Cornea Specularity' {Min:0, Max:1}", Float) = 0.36
	_EyeRoughness ("'Cornea Roughness' {Min:0, Max:1}", Float) = 0
	
	// Iris Properties 
	_IrisProperties ("'Iris Properties' {Section:{126, 118, 41}}", Float) = 0
	_EyeColor ("'Tint' {}", Color) = (1,1,1)
	_EyeIrisScattering ("'Scattering' {Min:0, Max:1}", Float) = 0
	_EyeSpecularTint ("'Specular Tint' {Min:0, Max:1}", Float) = 1
	_EyeParallax ("'Depth' {Min:0, Max:0.08}", Float) = 0.08
	_EyePupilSize ("'Pupil Dilation' {Min:0, Max:1}", Float) = 0

	// Detail Properties
	[Toggle(_DETAIL_ON)] 
	_DetailT ("'Detail Properties' {Feature:{57, 126, 41}}", Float) = 0
	[Enum(Mul, 0, MulX2, 1)] 
	_DetailMode ("'Mode' {Dropdown:{Mul:{}, MulX2:{}}}", Float) = 0
	_DetailWeight ("'Weight' {Min:0, Max:1}", Float) = 1
	_DetailAlbedoMap ("'Color' {Visualize:{RGB}}", 2D) = "white" {}
	_DetailAlbedoMapVelocity ("Scroll", Vector) = (0,0,0,0) 
	_DetailAlbedoMapUV ("UV Set", Float) = 0
	_DetailMaterialMap ("'AO(G) Variance(A)' {Visualize:{G, A}, Parent:_DetailAlbedoMap}", 2D) = "white" {}
	_DetailNormalMap ("'Normals' {Visualize:{NRM}, Parent:_DetailAlbedoMap}", 2D) = "bump" {}
	_DetailOcclusion ("'Occlusion Strength' {Min:0, Max:1}", Float) = 1
	_DetailNormalMapScale ("'Normal Strength' {}", Float) = 1

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

SubShader {
    Tags { 
        "Queue"="Geometry" 
        "RenderType"="Opaque"
    }
    LOD 400

	Pass {
		Name "FORWARD" 
		Tags { "LightMode" = "ForwardBase" }

		CGPROGRAM
		#pragma target 3.0
		#pragma exclude_renderers gles
		
		#pragma shader_feature _DETAIL_ON
		#pragma shader_feature _DECAL_ON
		#pragma shader_feature _EMISSION
		#pragma shader_feature _RIM_ON
		#pragma shader_feature _DISSOLVE_ON
		
		#pragma multi_compile_fwdbase
		#pragma multi_compile_fog
			
		#pragma vertex AlloyVertexForwardBase
		#pragma fragment AlloyFragmentForwardBase
		
		#define UNITY_PASS_FORWARDBASE
		
		#include "Assets/Alloy/Shaders/Definitions/Eyeball.cginc"
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
		
		#pragma shader_feature _DETAIL_ON
		#pragma shader_feature _DECAL_ON
		#pragma shader_feature _DISSOLVE_ON
		
		#pragma multi_compile_fwdadd_fullshadows
		#pragma multi_compile_fog
		
		#pragma vertex AlloyVertexForwardAdd
		#pragma fragment AlloyFragmentForwardAdd

		#define UNITY_PASS_FORWARDADD

		#include "Assets/Alloy/Shaders/Definitions/Eyeball.cginc"
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
		
		#include "Assets/Alloy/Shaders/Definitions/Eyeball.cginc"
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
		#pragma shader_feature _DECAL_ON
		#pragma shader_feature _EMISSION
		#pragma shader_feature _RIM_ON
		#pragma shader_feature _DISSOLVE_ON
				
		#pragma vertex AlloyVertexMeta
		#pragma fragment AlloyFragmentMeta
		
		#define UNITY_PASS_META
		
		#include "Assets/Alloy/Shaders/Definitions/Eyeball.cginc"
		#include "Assets/Alloy/Shaders/Passes/Meta.cginc"

		ENDCG
	}
}

FallBack "VertexLit"
CustomEditor "AlloyFieldBasedEditor"
}

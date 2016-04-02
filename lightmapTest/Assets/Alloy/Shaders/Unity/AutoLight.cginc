#ifndef AUTOLIGHT_INCLUDED
#define AUTOLIGHT_INCLUDED

#include "Assets/Alloy/Shaders/Framework/Lighting.cginc"

#include "HLSLSupport.cginc"
#include "UnityShadowLibrary.cginc"

#if (SHADER_TARGET < 30) || defined(SHADER_API_MOBILE)
	// We prefer performance over quality on SM2.0 and Mobiles
	// mobile or SM2.0: half precision for shadow coords
	#if defined (SHADOWS_NATIVE)
		#define unityShadowCoord half
		#define unityShadowCoord2 half2
		#define unityShadowCoord3 half3
	#else
		#define unityShadowCoord float
		#define unityShadowCoord2 float2
		#define unityShadowCoord3 float3
	#endif	
#if defined(SHADER_API_PSP2)
	#define unityShadowCoord4 float4	// Vita PCF only works when using float4 with tex2Dproj, doesn't work with half4.
#else
	#define unityShadowCoord4 half4
#endif
	#define unityShadowCoord4x4 half4x4
#else
	#define unityShadowCoord float
	#define unityShadowCoord2 float2
	#define unityShadowCoord3 float3
	#define unityShadowCoord4 float4
	#define unityShadowCoord4x4 float4x4
#endif


// ----------------
//  Shadow helpers
// ----------------

// ---- Screen space shadows
#if defined (SHADOWS_SCREEN)


#define SHADOW_COORDS(idx1) unityShadowCoord4 _ShadowCoord : TEXCOORD##idx1;

#if defined(UNITY_NO_SCREENSPACE_SHADOWS)

UNITY_DECLARE_SHADOWMAP(_ShadowMapTexture);
#define TRANSFER_SHADOW(a) a._ShadowCoord = mul( unity_World2Shadow[0], mul( _Object2World, v.vertex ) );

inline fixed unitySampleShadow (unityShadowCoord4 shadowCoord)
{
	#if defined(SHADOWS_NATIVE)

	fixed shadow = UNITY_SAMPLE_SHADOW(_ShadowMapTexture, shadowCoord.xyz);
	shadow = _LightShadowData.r + shadow * (1-_LightShadowData.r);
	return shadow;

	#else

	unityShadowCoord dist = SAMPLE_DEPTH_TEXTURE_PROJ(_ShadowMapTexture, shadowCoord);

	// tegra is confused if we use _LightShadowData.x directly
	// with "ambiguous overloaded function reference max(mediump float, float)"
	half lightShadowDataX = _LightShadowData.x;
	return max(dist > (shadowCoord.z/shadowCoord.w), lightShadowDataX);

	#endif
}

#else // UNITY_NO_SCREENSPACE_SHADOWS

sampler2D _ShadowMapTexture;
#define TRANSFER_SHADOW(a) a._ShadowCoord = ComputeScreenPos(a.pos);

inline fixed unitySampleShadow (unityShadowCoord4 shadowCoord)
{
	fixed shadow = tex2Dproj( _ShadowMapTexture, UNITY_PROJ_COORD(shadowCoord) ).r;
	return shadow;
}

#endif

#define SHADOW_ATTENUATION(a) unitySampleShadow(a._ShadowCoord)

#endif


// ---- Spot light shadows
#if defined (SHADOWS_DEPTH) && defined (SPOT)
	#define SHADOW_COORDS(idx1) unityShadowCoord4 _ShadowCoord : TEXCOORD##idx1;
	#define TRANSFER_SHADOW(a) a._ShadowCoord = mul (unity_World2Shadow[0], mul(_Object2World,v.vertex));
	#define SHADOW_ATTENUATION(a) UnitySampleShadowmap(a._ShadowCoord)
#endif


// ---- Point light shadows
#if defined (SHADOWS_CUBE)
	#define SHADOW_COORDS(idx1) unityShadowCoord3 _ShadowCoord : TEXCOORD##idx1;
	#define TRANSFER_SHADOW(a) a._ShadowCoord = mul(_Object2World, v.vertex).xyz - _LightPositionRange.xyz;
	#define SHADOW_ATTENUATION(a) UnitySampleShadowmap(a._ShadowCoord)
#endif

// ---- Shadows off
#if !defined (SHADOWS_SCREEN) && !defined (SHADOWS_DEPTH) && !defined (SHADOWS_CUBE)
	#define SHADOW_COORDS(idx1)
	#define TRANSFER_SHADOW(a)
	#define SHADOW_ATTENUATION(a) 1.0
#endif


// ------------------------------
//  Light helpers (5.0+ version)
// ------------------------------

half AlloyUnityAreaLight(
	unityShadowCoord3 lightCoord, 
	float3 positionWorld, 
	half3 normalWorld, 
	out fixed3 lightDir, 
	out half solidAngle) 
{
	float3 viewDirWorld = normalize(UnityWorldSpaceViewDir(positionWorld.xyz));
	float3 R = reflect(-viewDirWorld, normalize(normalWorld));
	
	// Trick to obtain light range for point lights from projected coordinates.
	// cf http://forum.unity3d.com/threads/get-the-range-of-a-point-light-in-forward-add-mode.213430/#post-1433291
	float3 lightVector = UnityWorldSpaceLightDir(positionWorld.xyz);
	half lightRange = length(lightVector) / length(lightCoord);
	half lightSize = _LightColor0.a * lightRange;
	
	return AlloySphereLight(lightSize, 1.0h / lightRange, lightVector, R, lightDir, solidAngle);
}

// This version depends on having worldPos available in the fragment shader and using that to compute light coordinates.

// If none of the keywords are defined, assume directional?
#if !defined(POINT) && !defined(SPOT) && !defined(DIRECTIONAL) && !defined(POINT_COOKIE) && !defined(DIRECTIONAL_COOKIE)
#define DIRECTIONAL
#endif

#ifdef POINT
uniform sampler2D _LightTexture0;
uniform unityShadowCoord4x4 _LightMatrix0;
#define UNITY_LIGHT_ATTENUATION(destName, input, worldPos) \
	unityShadowCoord3 lightCoord = mul(_LightMatrix0, unityShadowCoord4(worldPos, 1)).xyz; \
	fixed destName = AlloyUnityAreaLight(lightCoord.xyz, worldPos, o.Normal, lightDir, o.AreaLightSolidAngle) * SHADOW_ATTENUATION(input);
#endif

#ifdef SPOT
uniform sampler2D _LightTexture0;
uniform unityShadowCoord4x4 _LightMatrix0;
uniform sampler2D _LightTextureB0;
inline fixed UnitySpotCookie(unityShadowCoord4 LightCoord)
{
	return tex2D(_LightTexture0, LightCoord.xy / LightCoord.w + 0.5).w;
}
inline fixed UnitySpotAttenuate(unityShadowCoord3 LightCoord)
{
	return tex2D(_LightTextureB0, dot(LightCoord, LightCoord).xx).UNITY_ATTEN_CHANNEL;
}

#define UNITY_LIGHT_ATTENUATION(destName, input, worldPos) \
	unityShadowCoord4 lightCoord = mul(_LightMatrix0, unityShadowCoord4(worldPos, 1)); \
	fixed destName = AlloyUnityAreaLight(lightCoord.xyz, worldPos, o.Normal, lightDir, o.AreaLightSolidAngle) * (lightCoord.z > 0) * UnitySpotCookie(lightCoord) * SHADOW_ATTENUATION(input);
#endif


#ifdef DIRECTIONAL
	#define UNITY_LIGHT_ATTENUATION(destName, input, worldPos)	fixed destName = SHADOW_ATTENUATION(input);
#endif


#ifdef POINT_COOKIE
uniform samplerCUBE _LightTexture0;
uniform unityShadowCoord4x4 _LightMatrix0;
uniform sampler2D _LightTextureB0;
#define UNITY_LIGHT_ATTENUATION(destName, input, worldPos) \
	unityShadowCoord3 lightCoord = mul(_LightMatrix0, unityShadowCoord4(worldPos, 1)).xyz; \
	fixed destName = AlloyUnityAreaLight(lightCoord.xyz, worldPos, o.Normal, lightDir, o.AreaLightSolidAngle) * texCUBE(_LightTexture0, lightCoord).w * SHADOW_ATTENUATION(input);
#endif

#ifdef DIRECTIONAL_COOKIE
uniform sampler2D _LightTexture0;
uniform unityShadowCoord4x4 _LightMatrix0;
#define UNITY_LIGHT_ATTENUATION(destName, input, worldPos) \
	unityShadowCoord2 lightCoord = mul(_LightMatrix0, unityShadowCoord4(worldPos, 1)).xy; \
	fixed destName = tex2D(_LightTexture0, lightCoord).w * SHADOW_ATTENUATION(input);
#endif


// -----------------------------
//  Light helpers (4.x version)
// -----------------------------

// This version computes light coordinates in the vertex shader and passes them to the fragment shader.

#ifdef POINT
#define LIGHTING_COORDS(idx1,idx2) unityShadowCoord3 _LightCoord : TEXCOORD##idx1; SHADOW_COORDS(idx2)
#define TRANSFER_VERTEX_TO_FRAGMENT(a) a._LightCoord = mul(_LightMatrix0, mul(_Object2World, v.vertex)).xyz; TRANSFER_SHADOW(a)
#define LIGHT_ATTENUATION(a)	(tex2D(_LightTexture0, dot(a._LightCoord,a._LightCoord).rr).UNITY_ATTEN_CHANNEL * SHADOW_ATTENUATION(a))
#endif

#ifdef SPOT
#define LIGHTING_COORDS(idx1,idx2) unityShadowCoord4 _LightCoord : TEXCOORD##idx1; SHADOW_COORDS(idx2)
#define TRANSFER_VERTEX_TO_FRAGMENT(a) a._LightCoord = mul(_LightMatrix0, mul(_Object2World, v.vertex)); TRANSFER_SHADOW(a)
#define LIGHT_ATTENUATION(a)	( (a._LightCoord.z > 0) * UnitySpotCookie(a._LightCoord) * UnitySpotAttenuate(a._LightCoord.xyz) * SHADOW_ATTENUATION(a) )
#endif

#ifdef DIRECTIONAL
	#define LIGHTING_COORDS(idx1,idx2) SHADOW_COORDS(idx1)
	#define TRANSFER_VERTEX_TO_FRAGMENT(a) TRANSFER_SHADOW(a)
	#define LIGHT_ATTENUATION(a)	SHADOW_ATTENUATION(a)
#endif

#ifdef POINT_COOKIE
#define LIGHTING_COORDS(idx1,idx2) unityShadowCoord3 _LightCoord : TEXCOORD##idx1; SHADOW_COORDS(idx2)
#define TRANSFER_VERTEX_TO_FRAGMENT(a) a._LightCoord = mul(_LightMatrix0, mul(_Object2World, v.vertex)).xyz; TRANSFER_SHADOW(a)
#define LIGHT_ATTENUATION(a)	(tex2D(_LightTextureB0, dot(a._LightCoord,a._LightCoord).rr).UNITY_ATTEN_CHANNEL * texCUBE(_LightTexture0, a._LightCoord).w * SHADOW_ATTENUATION(a))
#endif

#ifdef DIRECTIONAL_COOKIE
#define LIGHTING_COORDS(idx1,idx2) unityShadowCoord2 _LightCoord : TEXCOORD##idx1; SHADOW_COORDS(idx2)
#define TRANSFER_VERTEX_TO_FRAGMENT(a) a._LightCoord = mul(_LightMatrix0, mul(_Object2World, v.vertex)).xy; TRANSFER_SHADOW(a)
#define LIGHT_ATTENUATION(a)	(tex2D(_LightTexture0, a._LightCoord).w * SHADOW_ATTENUATION(a))
#endif


#endif

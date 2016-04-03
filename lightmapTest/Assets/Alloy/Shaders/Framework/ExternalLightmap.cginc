//////////////////////////////////////////////////////////////////////////////
/// @file ExternalLightmap.cginc
/// @brief BRDF External lightmap support.
///////////////////////////////////////////////////////////////////////////////

#ifndef EXTERNAL_LIGHTMAP
#define EXTERNAL_LIGHTMAP

///////////////////////////////////////////////////////////////////////////////
/// Lightmap decalration
///////////////////////////////////////////////////////////////////////////////
sampler2D 	_externLightmap;		
half		_exLMIntensity;
half		_exLmAOeffect;
half  		_unityDiffuseLMEffect;
float 		_useUV1;
float 		_useRGBM;
float4		_exLM_HDRcoef;

half3 SampleLighmap(sampler2D LMtexture, float2 uv, half ao, half intensity){

	float4 lmColor = tex2D(LMtexture, uv);

	if(_useRGBM == 1)
	{
		lmColor.rgb = DecodeLightmapRGBM( lmColor, _exLM_HDRcoef );
	}
	
	return  lmColor* ao * intensity;
}

half3 ExternalLighmapGI(half3 albedo, float2 uv, half ao){
	return albedo * SampleLighmap(_externLightmap, uv, lerp (1, ao, _exLmAOeffect), _exLMIntensity);
}

half3 ExternalLighmapGI(half3 albedo, float4 uv01, half ao){
	// TODO : change this to #ifdef!!
	return albedo * SampleLighmap(_externLightmap, ((_useUV1 == 0)? uv01.xy : uv01.zw), lerp (1, ao, _exLmAOeffect), _exLMIntensity);
}

#endif // EXTERNAL_LIGHTMAP

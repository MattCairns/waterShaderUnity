Shader "Custom/WaterShader" {
	Properties {
		_Color ("Color", Color) = (0.8,0.9,0.6,1)
		_MainTex ("Albedo (RGBA)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0

		_Speed("Large Wave Speed", Range(0,50)) = 0.5
		_Amplitude("Large Wave Amplitute", Range(0,1)) = 0.5
		_Wavelength("Large Wave Wavelength", Range(0,10)) = 0.5
		_Q("Large Wave Steepness", range(0,2)) = 0.5

		_SpeedSmall("Small Wave Speed", Range(0,50)) = 0.5
		_AmplitudeSmall("Small Wave Amplitute", Range(0,1)) = 0.5
		_WavelengthSmall("Small Wave Wavelength", Range(0,1)) = 0.5
		_QSmall("Small Wave Steepness", range(0,2)) = 0.5
	}
	SubShader {
		Tags 
		{
			"Queue" = "Transparent"
			"RenderType"="Opaque"
		}
		ZWrite off
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows alpha
		#pragma vertex vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		#include "AutoLight.cginc"

		sampler2D _MainTex;
		float _Amplitude, _Speed, _Wavelength, _Q;
		float _AmplitudeSmall, _SpeedSmall, _WavelengthSmall, _QSmall;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		float3 gerstnerWaveSmall(float3 P, float2 D) 
		{
			//Gerstner waveform.  
			float W = sqrt(9.81 * (2  * 3.1416 / _WavelengthSmall));
			float dotD = dot(P.xz, D);
			float C = cos(W*dotD + _Time*_SpeedSmall);
			float S = sin(W*dotD + _Time*_SpeedSmall);
			return float3(P.x + _QSmall*_AmplitudeSmall*C*D.x, _AmplitudeSmall*S, P.z + _Q*_AmplitudeSmall*C*D.y);
		}

		float3 gerstnerWave(float3 P, float2 D)
		{
			//Gerstner waveform.  
			float W = sqrt(9.81 * (2 * 3.1416 / _Wavelength));
			float dotD = dot(P.xz, D);
			float C = cos(W*dotD + _Time*_Speed);
			float S = sin(W*dotD + _Time*_Speed);
			return float3(P.x + _Q*_Amplitude*C*D.x, _Amplitude*S, P.z + _Q*_Amplitude*C*D.y);
		}

		void vert(inout appdata_full v)
		{
			float3 P0 = v.vertex.xyz;
			//Sample points for normal recalculations.
			float3 P1 = P0 + float3(0.05, 0, 0); //+X
			float3 P2 = P0 + float3(0, 0, 0.05); //+Y

			//Wave directions.
			float2 D0 = float2(1, 0.5);
			float2 D1 = float2(0.75, 0.45);
			float2 D2 = float2(0.9, 0.5);
			float2 D3 = float2(0.85, 0.55);
			float2 D4 = float2(0, 1);
			float2 D5 = float2(0.75, 0.5);

			//Small wave directions
			float D6 = float2(0.2, 0.3);


			float3 Pv0 = gerstnerWave(P0, D0) + gerstnerWave(P0, D1) + gerstnerWave(P0, D2) + gerstnerWave(P0, D2) + gerstnerWave(P0, D4)
				+ gerstnerWave(P0, D5) + gerstnerWaveSmall(P0, D4) + gerstnerWaveSmall(P0, D6);
			float3 Pv1 = gerstnerWave(P1, D0) + gerstnerWave(P1, D1) + gerstnerWave(P1, D2) + gerstnerWave(P1, D2) + gerstnerWave(P1, D4)
				+ gerstnerWave(P1, D5) + gerstnerWaveSmall(P1, D4) + gerstnerWaveSmall(P0, D6);;
			float3 Pv2 = gerstnerWave(P2, D0) + gerstnerWave(P2, D1) + gerstnerWave(P2, D2) + gerstnerWave(P2, D2) + gerstnerWave(P2, D4)
				+ gerstnerWave(P2, D5) + gerstnerWaveSmall(P2, D4) + gerstnerWaveSmall(P0, D6);;

			//Take the cross product to find the normal of the vertices.
			float3 vn = cross(Pv2 - Pv0, Pv1 - Pv0);
			v.normal += normalize(vn);

			v.vertex.xyz += float4(Pv0, 1);
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG


	}

}

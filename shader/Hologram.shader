// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/Hologram"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (1, 0, 0, 1)
		_Bias("Bias", Float) = 0
		_ScanningFrequency ("Scanning Frequency", Float) = 100
		_ScanningSpeed ("Scanning Speed", Float) = 100
	}
	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
		LOD 100
		Zwrite off
		Blend SrcAlpha One
		cull off

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
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float4 objVertex: TEXCOORD1;
			};

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Bias;
			float _ScanningFrequency;
			float _ScanningSpeed;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.objVertex = mul(unity_ObjectToWorld,v.vertex);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				col = _Color * max(0, cos(i.objVertex.y * _ScanningFrequency + _Time.x * _ScanningSpeed) + _Bias);
				col *= 1 - max(0, cos(i.objVertex.x * _ScanningFrequency + _Time.x * _ScanningSpeed) + 0.9);
				col *= 1 - max(0, cos(i.objVertex.z * _ScanningFrequency + _Time.x * _ScanningSpeed) + 0.9);
				return col;
			}
			ENDCG
		}
	}
}

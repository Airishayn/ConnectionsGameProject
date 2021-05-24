Shader "AirsShader/DisplaceWithAudiolink"
{
    Properties
    {
        _MainTexture ("Texture", 2D) = "white" {}
        _Color("Colour", Color) = (1,1,1,1)
        _VertexOffset("Vertex Offset", Float) = (0,0,0,0)
        _AnimationSpeed("Animation Speed", Range(0,3)) = 0
        _OffsetSize("OffsetSize", Range(0,10)) = 0
        _PhaseOffset ("PhaseOffset", Range(0,1)) = 0
        _Speed ("Speed", Range(0.1,10)) = 1
        _Depthx ("Depth X", Range(0.01,1)) = 0.2
        _Depthy ("Depth Y", Range(0.01,1)) = 0.2
        _Depthz ("Depth Z", Range(0.01,1)) = 0.2
        _Scale ("Scale", Range(0.1,20)) = 10

        [HideInInspector] _texcoord( "", 2D ) = "white" {}

    }
    SubShader
    {
        Pass
        {
            Tags {"Queue"="Transparent+1" "IgnoreProjector"="True" "RenderType"="TransparentCutout" "LightMode" = "ForwardBase"}
            CGPROGRAM

            #pragma vertex vertexFunc
            #pragma fragment fragmentFunc
            #pragma target 3.0


            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

            #if defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))

        		#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex.Sample(samplerTex,coord)
        		#else
        		#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex2D(tex,coord)
        		#endif

            struct appdata{
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 diff : COLOR0;
            };

            /*struct INPUT{
              float2 uv_texcoord;
            };*/

            struct v2f
            {
              float4 position : SV_POSITION;
              float2 uv : TEXCOORD0;
              fixed4 diff :COLOR0;
            };

            fixed4 _VertexOffset;
            fixed4 _Color;
            sampler2D _MainTexture;
            float _AnimationSpeed;
            float _OffsetSize;
            float _PhaseOffset;
            float _Speed;
            float _Depthx;
            float _Depthy;
            float _Depthz;
            float _Scale;


            //Audiolink Stuff
            /*UNITY_DECLARE_TEX2D_NOSAMPLER(_AudioTexture);
            SamplerState sampler_AudioTexture;
            uniform float _AudioDelayPulseRotation;
            uniform float _ALRadHueOffset, _ALBrightness, _ALSaturate, _AudioTextureBrightness, _AudioTextureBrightnessA, _AudioTextureBrightness0 , _AudioTextureBrightness1, _AudioTextureBrightness2, _AudioTextureBrightness3;

        		float If_AudioTextureExists7(  )
        		{
        			float w = 0;
        			float h;
        			float res = 0;
        			#ifndef SHADER_TARGET_SURFACE_ANALYSIS
        			_AudioTexture.GetDimensions(w, h);
        			#endif
        			if (w == 32) res = 1;
        			return res;
        		}

            void surf (appdata_full IN, INPUT IN2)
            {

         float localIf_AudioTextureExists7 = If_AudioTextureExists7();
         float audioTextureEnabled8 = localIf_AudioTextureExists7;
         float2 break6_g4 = IN2.uv_texcoord;
         float temp_output_5_0_g4 = ( break6_g4.x - 0.5 );
         float temp_output_2_0_g4 = radians( _AudioDelayPulseRotation );
         float temp_output_3_0_g4 = cos( temp_output_2_0_g4 );
         float temp_output_8_0_g4 = sin( temp_output_2_0_g4 );
         float temp_output_20_0_g4 = ( 1.0 / ( abs( temp_output_3_0_g4 ) + abs( temp_output_8_0_g4 ) ) );
         float temp_output_7_0_g4 = ( break6_g4.y - 0.5 );

         float2 BandA = (float2(( ( ( temp_output_5_0_g4 * temp_output_3_0_g4 * temp_output_20_0_g4 ) + ( temp_output_7_0_g4 * temp_output_8_0_g4 * temp_output_20_0_g4 ) ) + 0.5 ) , ( ( ( temp_output_7_0_g4 * temp_output_3_0_g4 * temp_output_20_0_g4 ) - ( temp_output_5_0_g4 * temp_output_8_0_g4 * temp_output_20_0_g4 ) ) + 0.5 )));

         float2 Band0 = float2( BandA.x , ( ( 0 * 0.25 ) + 0.125 ));

         float2 Band1 = float2( BandA.x , ( ( 1 * 0.25 ) + 0.125 ));

         float2 Band2 = float2( BandA.x , ( ( 2 * 0.25 ) + 0.125 ));

         float2 Band3 = float2( BandA.x , ( ( 3 * 0.25 ) + 0.125 ));

               float2 AudioMix =
         (BandA * _AudioTextureBrightnessA) +
         (Band0 * _AudioTextureBrightness0) +
         (Band1 * _AudioTextureBrightness1) +
         (Band2 * _AudioTextureBrightness2) +
         (Band3 * _AudioTextureBrightness3);

         OUT.Low = Band0
         OUT.MidLow = Band1
         OUT.MidHigh = Band2
         OUT.High = Band3

         Return OUT
       }*/



            v2f vertexFunc( appdata_full IN)
            {
              v2f OUT;

              //Lighting Stuff

              OUT.position = UnityObjectToClipPos(IN.vertex);
              OUT.uv = IN.texcoord;
              //get vertex normal in world space
              half3 worldNormal = UnityObjectToWorldNormal(IN.normal);
              //dot product between normal and light direction for standard diffuse Lighting
              half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
              // factor in light Color
              OUT.diff = nl * _LightColor0;



              //Obtain tangent space rotation matrix
              float3 binormal = cross( IN.normal, IN.tangent.xyz ) * IN.tangent.w;
              float3x3 rotation = transpose( float3x3( IN.tangent.xyz, binormal, IN.normal ));

              //Create two vectors, put them in tangent space, normalize them, then half them
              float3 v1 = normalize( mul( rotation, float3(0.1, 0, 1))) * 0.5;
              float3 v2 = normalize( mul( rotation, float3(0, 0.1, 1))) * 0.5;

              //Some animation values
              float phase = _PhaseOffset * 3.14 * 2;
              float speed = _Time.y * _Speed;

              //Modify the real vertex and the two theoretical vertexes by the distortion
              IN.vertex.x += sin( phase * .3 + speed + (IN.vertex.z * _Scale)) * .5 * _Depthx;
              IN.vertex.y += sin( phase * .6 + speed * 1.2 + (IN.vertex.z * _Scale ))* .5 * _Depthy;
              IN.vertex.z += sin( phase + speed * 1.4 + (IN.vertex.z * _Scale )) * .5 * _Depthz;
              v1.x += sin( phase + speed + (v1.z * _Scale)) * _Depthx;
              v2.x += sin( phase + speed + (v2.z * _Scale)) * _Depthx;

              //Take the cross product of sampled positions and make the dynamic normal
              float3 vertexNew = cross( v2-IN.vertex.xyz, v1-IN.vertex.xyz);

              //normalize
              IN.normal = normalize( vertexNew );

              //IN.vertex += _VertexOffset;
              //IN.vertex.x += sin(_Time.y * _AnimationSpeed + IN.vertex.y * _OffsetSize);
              OUT.position = UnityObjectToClipPos(IN.vertex);
              //OUT.uv = IN.uv;

              return OUT;
            }

            fixed4 fragmentFunc(v2f IN) : SV_Target
            {
              fixed4 pixelColor = tex2D(_MainTexture, IN.uv);

            return pixelColor * _Color;
            }

            ENDCG
        }
    }

    FallBack "Transparent/Cutout/Diffuse"
}

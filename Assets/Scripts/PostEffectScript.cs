using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class PostEffectScript : MonoBehaviour {

    public Material mat;

	void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Graphics.Blit(src, dest, mat);
    }
}

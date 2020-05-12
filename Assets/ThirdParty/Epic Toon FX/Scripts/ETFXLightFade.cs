using UnityEngine;
using System.Collections;

namespace EpicToonFX
{
    public class ETFXLightFade : MonoBehaviour
    {
        [Header("Seconds to dim the light")]
        public float life = 0.2f;
        public bool killAfterLife = true;

        private Light li;
        private float initIntensity;

        void Start()
        {
			li = gameObject.GetComponent<Light>();
            if (li)
            {
                initIntensity = li.intensity;
            }
            else
                print("No light object found on " + gameObject.name);
        }

        void Update()
        {
            if (li)
            {
                li.intensity -= initIntensity * (Time.deltaTime / life);
                if (killAfterLife && li.intensity <= 0){
					Destroy(li);
				}
            }
        }
    }
}
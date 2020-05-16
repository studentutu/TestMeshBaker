// using System.Collections;
// using System.Collections.Generic;
// using UnityEngine;
// using UnityEngine.Rendering.Universal;

// public class AddToStackNewCameras : MonoBehaviour
// {
//     [SerializeField] private Camera mainCam = null;
//     private bool working = true;
//     private void Awake()
//     {
//         StartCoroutine(waitFor10Seconds());
//     }
//     private IEnumerator waitFor10Seconds()
//     {
//         yield return new WaitForSeconds(10);
//         working = false;
//     }
//     // Update is called once per frame
//     private void Update()
//     {
//         if (working)
//         {
//             var allCams = Camera.allCameras;
//             var cameraData = mainCam.GetUniversalAdditionalCameraData();
//             int i = 0;
//             foreach (var item in allCams)
//             {
//                 if (item == mainCam)
//                 {
//                     continue;
//                 }
//                 item.enabled = false;
//                 // if (!cameraData.cameraStack.Contains(item))
//                 // {
//                 //     var data = item.GetUniversalAdditionalCameraData();
//                 //     data.renderType = CameraRenderType.Overlay;
//                 //     cameraData.cameraStack.Add(item);
//                 // }

//             }
//         }
//     }
// }

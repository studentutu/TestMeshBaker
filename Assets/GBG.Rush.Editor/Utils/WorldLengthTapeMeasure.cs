namespace GBG.Rush.Editor.Utils {
    using System;
    using Sirenix.OdinInspector;
    using UnityEditor;
    using UnityEngine;

    [ExecuteAlways]
    [AddComponentMenu("")]
    public class WorldLengthTapeMeasure : MonoBehaviour {
        private static readonly Vector3 InitScale = new Vector3(0.1f, 0.1f, 10f);

        public enum MeasureAxis {
            X,
            Y,
            Z
        }

        public MeasureAxis axis;

        [ReadOnly]
        [SerializeField]
        private float distance;

        private Transform start;
        private Transform end;

        private void Update() {
            this.ReCalculate();
        }

        [Button]
        private void ReCalculate() {
            switch (this.axis) {
                case MeasureAxis.X:
                    this.distance = CalculateDistance(this.start.position.x, this.end.position.x, this.start.lossyScale.x, this.end.lossyScale.x);
                    break;
                case MeasureAxis.Y:
                    this.distance = CalculateDistance(this.start.position.y, this.end.position.y, this.start.lossyScale.y, this.end.lossyScale.y);
                    break;
                case MeasureAxis.Z:
                    this.distance = CalculateDistance(this.start.position.z, this.end.position.z, this.start.lossyScale.z, this.end.lossyScale.z);
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
        }

        private static float CalculateDistance(float startPosition, float endPosition, float startScale, float endScale) {
            var distance = Math.Abs(startPosition - endPosition);
            if (distance <= 0) return distance;

            distance -= startScale / 2;
            distance -= endScale / 2;
            return distance;
        }

        [MenuItem("GameObject/3D Object/" + nameof(WorldLengthTapeMeasure), false, 1000)]
        private static void CreateInstaller(MenuCommand menuCommand) {
            var go = new GameObject("[TapeMeasure]") {
                hideFlags = HideFlags.DontSave
            };

            GameObjectUtility.SetParentAndAlign(go, menuCommand.context as GameObject);
            Undo.RegisterCreatedObjectUndo(go, $"Create {go.name}");
            Selection.activeObject = go;

            var tape = go.AddComponent<WorldLengthTapeMeasure>();
            tape.start = CreateOneEnd(go, "[Start]");
            tape.end   = CreateOneEnd(go, "[End]");
        }

        private static Transform CreateOneEnd(GameObject parent, string name) {
            var end = GameObject.CreatePrimitive(PrimitiveType.Cube).transform;
            end.gameObject.hideFlags = HideFlags.DontSave;
            end.name                 = name;
            end.localScale           = InitScale;
            end.SetParent(parent.transform);
            return end;
        }
    }
}
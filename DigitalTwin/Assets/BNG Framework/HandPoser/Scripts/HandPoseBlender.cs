﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace BNG {
    public class HandPoseBlender : MonoBehaviour {

        [Header("Run in Update")]
        [Tooltip("If true the HandPoser will be updated in Update by reading ThumbValue, IndexValue, and GripValue")]
        public bool UpdatePose = true;

        [Header("Blend From / To")]
        [Tooltip("(Required) Blend from this hand pose to the Pose2 hand pose.")]
        public HandPose Pose1;

        [Tooltip("(Required) Blend from the Pose1 hand pose to this hand pose.")]
        public HandPose Pose2;

        [Header("Inputs")]
        [Range(0, 1)]
        public float ThumbValue = 0f;
        // private float _lastThumbValue = 0;

        [Range(0, 1)]
        public float IndexValue = 0f;
        // private float _lastIndexValue = 0;

        [Range(0, 1)]
        public float MiddleValue = 0f;
        // private float _lastMiddleValue = 0;

        [Range(0, 1)]
        public float RingValue = 0f;
        // private float _lastRingValue = 0;

        [Range(0, 1)]
        public float PinkyValue = 0f;
        // private float _lastPinkyValue = 0;

        [Range(0, 1)]
        public float GripValue = 0f;
        private float _lastGripValue;

        protected HandPoser handPoser;

        bool updatedPoseLastFrame = false;

        void Start() {
            handPoser = GetComponent<HandPoser>();
        }

        void Update() {
            if (UpdatePose) {
                UpdatePoseFromInputs();

                updatedPoseLastFrame = true;
            }
            else {
                updatedPoseLastFrame = false;
            }
        }

        float indexBlendMin = 0f;
        float indexBlendMax = 1f;

        float thumbBlendMin = 0f;
        float thumbBlendMax = 1f;

        public virtual void ResetBlendRatios() {
            indexBlendMin = 0f;
            indexBlendMax = 1f;
            thumbBlendMin = 0f;
            thumbBlendMax = 1f;
        }

        public virtual void SetIndexBlend(float minBlendAmount, float maxBlendAmount) {
            indexBlendMin = minBlendAmount;
            indexBlendMax = maxBlendAmount;
        }

        public virtual void SetThumbBlend(float minBlendAmount, float maxBlendAmount) {
            thumbBlendMin = minBlendAmount;
            thumbBlendMax = maxBlendAmount;
        }

        /// <summary>
        /// Update the hand pose based on ThumbValue, IndexValue, and GripValue
        /// </summary>
        public virtual void UpdatePoseFromInputs() {
            DoIdleBlendPose();
        }

        public void UpdateThumb(float amount) {
            float adjustAmount = Mathf.Lerp(thumbBlendMin, thumbBlendMax, amount);
            handPoser.UpdateJoints(Pose2.Joints.ThumbJoints, handPoser.ThumbJoints, adjustAmount);
        }

        public void UpdateIndex(float amount) {
            float adjustAmount = Mathf.Lerp(indexBlendMin, indexBlendMax, amount);
            handPoser.UpdateJoints(Pose2.Joints.IndexJoints, handPoser.IndexJoints, adjustAmount);
        }

        public void UpdateMiddle(float amount) {
            handPoser.UpdateJoints(Pose2.Joints.MiddleJoints, handPoser.MiddleJoints, MiddleValue);
        }

        public void UpdateRing(float amount) {
            handPoser.UpdateJoints(Pose2.Joints.RingJoints, handPoser.RingJoints, amount);
        }

        public void UpdatePinky(float amount) {
            handPoser.UpdateJoints(Pose2.Joints.PinkyJoints, handPoser.PinkyJoints, amount);
        }

        /// <summary>
        /// Shortcut for updating the middle, ring, and pinky fingers together
        /// </summary>
        /// <param name="amount"></param>
        public void UpdateGrip(float amount) {
            // Then lerp the pinky, ring, and middle finger joints to the Fist position based on grip amount
            MiddleValue = amount;
            RingValue = amount;
            PinkyValue = amount;

            UpdateMiddle(amount);
            UpdateRing(amount);
            UpdatePinky(amount);

            _lastGripValue = amount;
        }

        public virtual void DoIdleBlendPose() {
            if (Pose1) {

                if(updatedPoseLastFrame && handPoser.doSingleAnimation && GripValue == 0 && IndexValue == 0) {
                    handPoser.ResetAnimationState();
                }

                // Start at idle
                handPoser.UpdateHandPose(Pose1, false);

                // Then lerp each finger to fist pose depending on input
                UpdateThumb(ThumbValue);
                UpdateIndex(IndexValue);

                // Set Grip Amount only if it changed. This will override Middle, Ring, and Pinky
                if (GripValue != _lastGripValue) {
                    UpdateGrip(GripValue);
                }
                // Otherwise update the remaining fingers independently
                else {
                    UpdateMiddle(MiddleValue);
                    UpdateRing(RingValue);
                    UpdatePinky(PinkyValue);
                }
            }
        }        
    }
}


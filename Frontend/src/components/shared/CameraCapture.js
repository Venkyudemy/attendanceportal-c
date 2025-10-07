import React, { useState, useRef, useCallback } from 'react';
import './CameraCapture.css';

const CameraCapture = ({ onCapture, onClose, type }) => {
  const [stream, setStream] = useState(null);
  const [capturedImage, setCapturedImage] = useState(null);
  const [error, setError] = useState(null);
  const [isStreaming, setIsStreaming] = useState(false);
  const videoRef = useRef(null);
  const canvasRef = useRef(null);
  const streamRef = useRef(null); // Use ref to track stream for cleanup

  // Start camera
  const startCamera = useCallback(async () => {
    try {
      setError(null);
      console.log('🎥 Requesting camera access...');
      
      // Check if navigator.mediaDevices is available
      if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
        throw new Error('Camera API not supported in this browser');
      }
      
      const mediaStream = await navigator.mediaDevices.getUserMedia({
        video: {
          width: { ideal: 1280 },
          height: { ideal: 720 },
          facingMode: 'user'
        },
        audio: false
      });
      
      console.log('✅ Camera access granted');
      streamRef.current = mediaStream; // Store in ref for cleanup
      setStream(mediaStream);
      
      if (videoRef.current) {
        videoRef.current.srcObject = mediaStream;
        // Wait for video to be ready before marking as streaming
        videoRef.current.onloadedmetadata = () => {
          console.log('📹 Video metadata loaded');
          videoRef.current.play().then(() => {
            console.log('▶️ Video playing');
            setIsStreaming(true);
          }).catch(err => {
            console.error('Error playing video:', err);
            setError('Failed to start video playback');
          });
        };
      }
    } catch (err) {
      console.error('❌ Error accessing camera:', err);
      let errorMessage = 'Unable to access camera. ';
      
      if (err.name === 'NotAllowedError' || err.name === 'PermissionDeniedError') {
        errorMessage += 'Please grant camera permissions in your browser settings.';
      } else if (err.name === 'NotFoundError' || err.name === 'DevicesNotFoundError') {
        errorMessage += 'No camera found on this device.';
      } else if (err.name === 'NotReadableError' || err.name === 'TrackStartError') {
        errorMessage += 'Camera is already in use by another application.';
      } else if (err.message.includes('not supported')) {
        errorMessage += 'Your browser does not support camera access.';
      } else {
        errorMessage += err.message || 'Unknown error occurred.';
      }
      
      setError(errorMessage);
    }
  }, []);

  // Stop camera
  const stopCamera = useCallback(() => {
    console.log('🛑 Stopping camera...');
    if (streamRef.current) {
      streamRef.current.getTracks().forEach(track => {
        console.log('Stopping track:', track.label);
        track.stop();
      });
      streamRef.current = null;
    }
    if (videoRef.current) {
      videoRef.current.srcObject = null;
    }
    setStream(null);
    setIsStreaming(false);
  }, []); // No dependencies - uses refs instead

  // Capture photo
  const capturePhoto = useCallback(() => {
    console.log('📸 Capturing photo...');
    if (videoRef.current && canvasRef.current) {
      const video = videoRef.current;
      const canvas = canvasRef.current;
      
      // Check if video is ready
      if (!video.videoWidth || !video.videoHeight) {
        console.error('Video not ready');
        setError('Video not ready. Please wait a moment and try again.');
        return;
      }
      
      const context = canvas.getContext('2d');

      // Set canvas size to match video
      canvas.width = video.videoWidth;
      canvas.height = video.videoHeight;
      
      console.log('Canvas size:', canvas.width, 'x', canvas.height);

      // Draw video frame to canvas (with mirror effect)
      context.save();
      context.scale(-1, 1); // Mirror horizontally
      context.drawImage(video, -canvas.width, 0, canvas.width, canvas.height);
      context.restore();

      // Convert canvas to blob (JPG format)
      canvas.toBlob((blob) => {
        if (blob) {
          console.log('✅ Photo captured:', blob.size, 'bytes');
          const imageUrl = URL.createObjectURL(blob);
          setCapturedImage({ url: imageUrl, blob });
          stopCamera();
        } else {
          console.error('Failed to create blob');
          setError('Failed to capture photo. Please try again.');
        }
      }, 'image/jpeg', 0.95);
    } else {
      console.error('Video or canvas ref not available');
    }
  }, [stopCamera]);

  // Retake photo
  const retakePhoto = useCallback(() => {
    if (capturedImage && capturedImage.url) {
      URL.revokeObjectURL(capturedImage.url);
    }
    setCapturedImage(null);
    startCamera();
  }, [capturedImage, startCamera]);

  // Confirm and use photo
  const confirmPhoto = useCallback(() => {
    if (capturedImage && capturedImage.blob) {
      onCapture(capturedImage.blob);
      stopCamera();
      if (capturedImage.url) {
        URL.revokeObjectURL(capturedImage.url);
      }
    }
  }, [capturedImage, onCapture, stopCamera]);

  // Close modal
  const handleClose = useCallback(() => {
    stopCamera();
    if (capturedImage && capturedImage.url) {
      URL.revokeObjectURL(capturedImage.url);
    }
    onClose();
  }, [stopCamera, capturedImage, onClose]);

  // Start camera on mount
  React.useEffect(() => {
    console.log('🎬 Component mounted, starting camera...');
    let mounted = true;
    
    // Add a small delay to ensure component is mounted
    const timer = setTimeout(() => {
      if (mounted) {
        startCamera();
      }
    }, 100);
    
    // Cleanup function
    return () => {
      console.log('🧹 Component unmounting, cleaning up...');
      mounted = false;
      clearTimeout(timer);
      
      // Clean up stream
      if (streamRef.current) {
        streamRef.current.getTracks().forEach(track => {
          console.log('Cleanup: Stopping track:', track.label);
          track.stop();
        });
        streamRef.current = null;
      }
      
      // Clean up video element
      if (videoRef.current) {
        videoRef.current.srcObject = null;
      }
    };
  }, []); // Empty dependency array - only run once on mount

  return (
    <div className="camera-capture-overlay">
      <div className="camera-capture-modal">
        <div className="camera-capture-header">
          <h3>📸 Capture Photo for {type === 'checkin' ? 'Check-In' : 'Check-Out'}</h3>
          <button className="close-button" onClick={handleClose}>×</button>
        </div>

        <div className="camera-capture-body">
          {error && (
            <div className="camera-error">
              <p>{error}</p>
              <button onClick={startCamera} className="retry-button">
                Retry
              </button>
            </div>
          )}

          {!capturedImage && !error && (
            <div className="camera-preview">
              {!isStreaming && (
                <div className="loading-camera">
                  <div className="spinner"></div>
                  <p>Starting camera...</p>
                </div>
              )}
              <video
                ref={videoRef}
                autoPlay
                playsInline
                muted
                className="video-stream"
                style={{ display: isStreaming ? 'block' : 'none' }}
              />
            </div>
          )}

          {capturedImage && (
            <div className="captured-preview">
              <img src={capturedImage.url} alt="Captured" className="captured-image" />
            </div>
          )}

          <canvas ref={canvasRef} style={{ display: 'none' }} />
        </div>

        <div className="camera-capture-footer">
          {!capturedImage && !error && isStreaming && (
            <>
              <button onClick={handleClose} className="cancel-button">
                Cancel
              </button>
              <button onClick={capturePhoto} className="capture-button">
                📷 Capture
              </button>
            </>
          )}
          
          {!capturedImage && !error && !isStreaming && (
            <button onClick={handleClose} className="cancel-button">
              Cancel
            </button>
          )}

          {capturedImage && (
            <>
              <button onClick={retakePhoto} className="retake-button">
                ↻ Retake
              </button>
              <button onClick={confirmPhoto} className="confirm-button">
                ✓ Confirm & Continue
              </button>
            </>
          )}
          
          {error && (
            <button onClick={handleClose} className="cancel-button">
              Close
            </button>
          )}
        </div>
      </div>
    </div>
  );
};

export default CameraCapture;


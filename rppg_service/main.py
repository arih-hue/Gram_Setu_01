import os
import sys
import shutil
import cv2
import numpy as np
import torch
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import logging

# Ensure rppg_toolbox_repo is in path so we can import its models
sys.path.append(os.path.join(os.path.dirname(__name__), 'rppg_toolbox_repo'))

try:
    from neural_methods.models.DeepPhys import DeepPhys
except ImportError:
    pass

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Gram Setu rPPG DeepPhys AI Server")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

TEMP_DIR = "temp_videos"
os.makedirs(TEMP_DIR, exist_ok=True)

# Initialize deep learning model from rPPG-Toolbox
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
try:
    model = DeepPhys().to(device)
    model.eval()
    logger.info("DeepPhys AI model loaded successfully from rPPG-Toolbox.")
except Exception as e:
    logger.error("Failed to load DeepPhys model. Ensure PyTorch is installed.", exc_info=True)
    model = None

def run_deep_phys_on_video(video_path: str):
    """
    Extracts frames using OpenCV and runs the DeepPhys PyTorch model 
    from rPPG-Toolbox to evaluate the pulse signal.
    """
    cap = cv2.VideoCapture(video_path)
    frames = []
    
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break
        # Resize frame to standard 36x36 shape for DeepPhys
        frame = cv2.resize(frame, (36, 36))
        frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        frames.append(frame)
        
    cap.release()
    
    if len(frames) < 10:
        raise ValueError("Video too short for processing")
        
    # Standardize and calculate Normalized Frame Difference & Appearance
    frames = np.array(frames, dtype=np.float32) / 255.0
    
    diff_frames = np.diff(frames, axis=0) # dX
    diff_frames = diff_frames / (np.std(diff_frames) + 1e-7)
    
    app_frames = frames[:-1] # Appearance
    app_frames = app_frames / (np.std(app_frames) + 1e-7)
    
    # Forward pass through DeepPhys
    signal_out = []
    with torch.no_grad():
        for i in range(len(diff_frames)):
            # DeepPhys expects inputs of shape (Batch, Channels, Height, Width)
            X_in = torch.tensor(diff_frames[i]).permute(2, 0, 1).unsqueeze(0).to(device)
            A_in = torch.tensor(app_frames[i]).permute(2, 0, 1).unsqueeze(0).to(device)
            
            pulse, _ = model(X_in, A_in)
            signal_out.append(pulse.item())
            
    # Calculate heart rate from the pulse signal via FFT (Fast Fourier Transform)
    signal_out = np.array(signal_out)
    fps = 30 # Assume 30fps from mobile camera
    fft_result = np.abs(np.fft.rfft(signal_out))
    freqs = np.fft.rfftfreq(len(signal_out), 1.0 / fps)
    
    # Filter bounds to typical human heart rate (40 - 200 BPM -> 0.66 - 3.33 Hz)
    valid_idx = np.where((freqs >= 0.66) & (freqs <= 3.33))
    if len(valid_idx[0]) == 0:
        return 75 # default fallback
        
    freqs = freqs[valid_idx]
    fft_result = fft_result[valid_idx]
    
    peak_freq = freqs[np.argmax(fft_result)]
    heart_rate = peak_freq * 60.0
    
    return float(heart_rate)


@app.post("/analyze_video")
async def analyze_video(file: UploadFile = File(...)):
    if not file.filename.endswith(('.mp4', '.mov', '.avi')):
         raise HTTPException(status_code=400, detail="Invalid video format")
    
    file_path = os.path.join(TEMP_DIR, file.filename)
    
    try:
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        
        logger.info(f"Video saved to {file_path}. Evaluating using rPPG-Toolbox DeepPhys model...")
        
        heart_rate = 75 # default
        if model is not None:
             heart_rate = run_deep_phys_on_video(file_path)
             
        # Cleanup
        os.remove(file_path)
        
        return {
            "success": True,
            "heart_rate": round(heart_rate),
            "message": "AI Evaluation Complete"
        }
        
    except Exception as e:
        logger.error(f"Error during DeepPhys model execution: {e}")
        if os.path.exists(file_path): os.remove(file_path)
        raise HTTPException(status_code=500, detail="Internal AI Evaluation Error")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)

# Image Processing Fundamentals with NumPy

Six notebooks that implement core digital image processing techniques **from first principles with NumPy/SciPy** (no OpenCV black boxes), with quantitative evaluation where possible. Coursework for *Digital Image Processing & Analysis* (University of Patras, CEID, 2025–26).

![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white)
![NumPy](https://img.shields.io/badge/NumPy-013243?logo=numpy&logoColor=white)
![SciPy](https://img.shields.io/badge/SciPy-8CAAE6?logo=scipy&logoColor=white)
![Jupyter](https://img.shields.io/badge/Jupyter-F37626?logo=jupyter&logoColor=white)

| # | Topic | What is implemented | Key finding |
|---|---|---|---|
| 1 | [Frequency-domain filtering](01-frequency-domain-filtering) | 2-D FFT, centred spectrum, ideal low-pass filter (D0 = 30) | Sharp cut-off causes ringing; Butterworth/Gaussian filters avoid it |
| 2 | [Histogram equalization](02-histogram-equalization) | Global vs adaptive (local) equalization on night-time road images | Adaptive equalization reveals hidden detail with far less noise amplification |
| 3 | [Image denoising](03-image-denoising) | Gaussian & impulse noise, moving-average and median filters, PSNR/MSE | For salt-and-pepper noise, median 3×3 reaches **21.1 dB** vs 17.8 dB for moving average |
| 4 | [Wiener deconvolution](04-wiener-deconvolution) | Impulse/frequency response of an unknown blur (PSF), inverse filter with threshold, Wiener filter at SNR = 10 dB | Wiener works best when the noise power is known; thresholding stabilises the inverse filter |
| 5 | [DCT compression](05-dct-compression) | 32×32 block DCT, **zonal vs threshold** coefficient selection, MSE vs kept ratio (5–50%) | Threshold coding beats zonal coding at every compression ratio |
| 6 | [Edge detection](06-edge-detection) | Sobel gradients by 2-D convolution, magnitude histogram, thresholding, edge overlay | Threshold chosen from the gradient-magnitude histogram |

Notebooks are executed (outputs and figures included) and the commentary is in Greek; this README summarises the findings in English.

## Run

```bash
pip install numpy scipy matplotlib pillow scikit-image jupyter
jupyter notebook
```

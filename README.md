# 🐻 Furmula: A Tactile Furry Calculator

A fully functional, skeuomorphic calculator built with **Flutter**, featuring a hyper-realistic "plush" interface where buttons actually feel pressed into the fur.

![me](https://github.com/FidaHussainST/Furmula/blob/main/Screenshots/video.gif)

## ✨ Features
* **Tactile UI:** Uses a custom "Overlay Method" to simulate buttons sinking into a fur texture.
* **Responsive Design:** Fully responsive layout that adapts to Phones, Tablets, and Web using `FittedBox` scaling.
* **Interactive Feedback:**
    * **Visual:** LED light glows green on input and red on errors.
    * **Audio:** Distinct sound effects for button clicks and calculation results.
* **Smart Logic:** Includes a history tape, LCD-style display, and error handling (e.g., Division by Zero detection).

## 🛠️ Tech Stack
* **Framework:** Flutter (Dart)
* **Audio:** `audioplayers` package
* **Design:** Custom Photoshop assets with feathered alpha channels for seamless blending.

## 🚀 How It Works
The app avoids heavy rendering by using a **Stack-based Overlay System**:
1.  **Layer 0:** A static background image of unpressed fur.
2.  **Layer 1:** The LCD text and LED indicators.
3.  **Layer 2:** Pre-cropped "pressed" button images with transparent feathering are overlayed at exact coordinates. They are invisible (`opacity: 0.0`) by default and fade in (`opacity: 1.0`) on tap.

## 📸 Screenshots
| Normal State | Error State (Red LED) |
| :---: | :---: |
| <img src="https://github.com/FidaHussainST/Furmula/blob/main/Screenshots/img.png" width="300"> | <img src="https://github.com/FidaHussainST/Furmula/blob/main/Screenshots/img_1.png" width="300"> |

## 📦 How to Run
1. Clone the repo:
   ```bash
   git clone https://github.com/FidaHussainST/Furmula.git

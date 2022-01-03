# WarpSpaceCraft
WarpSpaceCraft is a Side-Scroll-Shooter Game Weekend Projekt written in Pascal (Lazarus)

## Requirenments
- fpc >= 3.2
- Atomek61/LEDControls (included)
- ShapeCorner (included)
- BGRABitmap (Online Package Manager)
- Bass24 (included)

## Build in Lazarus Linux (Step by Step)

Import this project via git: 

```bash
git clone https://github.com/six1/WarpSpaceCraft.git 
```

Open this project in Lazarus (WarpSpaceCraft/Source).

### 1. Import ShapeCorner
Go in Lazarus in Package > Open Package File(.lpk) and import NewShape. You will find it in Sources/ShapeCorner.

### 2. Import BGRABitmap
BGRABitmap needs mesa-libGLU as requirenment.
Go in Package > Online Package Manager and import BGRABitmap.

### 3. Import LEDControls
Go in Package > Open Package File(.lpk) and import LEDControl.
You will find it in Sources/LEDControls-master

### 4. Install bass24 on Linux
Copy BassLinux/libbass.so in /lib64

### 5. Copy Assets into Source

Close the Project and open it again. WarpSpaceCraft project should now start without errors. Now you can press the 'Run' button or 'F9' and build the project.

Have fun with it!

## More informations
https://www.lazarusforum.de/viewtopic.php?f=11&t=13468

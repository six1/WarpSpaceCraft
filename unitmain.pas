unit unitMain;

// Six1  https://www.lazarusforum.de/
// Exclusion: I am not responsible if you go nuts about the game

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF Windows}
  Windows,
  {$endif}
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, LCLIntf, LCLType, BASS, FileUtil, ShapeCorner,
  Controls.SegmentDisplay, math
  ;

type TMusic = record
  Opening1,
  GameOver,
  Explosion,
  Shoot,
  ShipEngine,
  Background,
  Enemey,
  EnemyLaser,
  Astronaut,
  Cheat1,
  HumanNeutralised,
  Continue,
  AstronautSpeech,
  ThrottleUp
  :integer;
  end;

type TSpaceCraft = record
  SpeedUp:integer;
  SpeedDown:integer;
  SpeedLeft:integer;
  SpeedRight:integer;
  FireSpeed:Integer;
  FireSpeedCount:integer;
end;

type
  TShoot = record
    pic:TImage;
    sidewaysDirection:integer;
    sidewaysAngle:integer;
  end;

type
  TAstronaut = record
    Image:TImage;
    StartPointDifX:single;
    StepY:single;
    StepX:single;
    CountX:single;
    CountY:single;
    StartPointCountY:integer;
    ZoomMin {in Px}:integer;
    ZoomMax {in Px}:integer;
    ZoomFaktor:single;
    ZoomCount:single;
  end;

type
  TEnemy = record
    Pic:TImage;
    action:integer; // 0=straight 1=diagonal 2=hyperbole
    direction:integer; // 0=up 1=down
    StepX:single;
    StepY:single;
    StepCountX:single;
    StepCountY:single;
    amplitude:integer;
    Count:single;
    CountDir:integer;
    top:integer
  end;

type
  TExplosion = record
    pic:TImage;
    count,
    max:integer;
  end;

type TSpecialObject = record
   pic:TImage;
   active:boolean;
   XDirection:integer; // 0=left  1=right
   YDirection:integer; // 0=up  1=down
   goX : integer; // 0=no  1=yes
   goY : integer; // 0=no  1=yes
   goZ : integer; // 0=no  1=yes
   ZSpeed:single;
   XSpeed:integer;
   YSpeed:integer;
   MoveCount:single;
end;

type

  { TForm1 }

  TForm1 = class(TForm)
    CollisionLamp1: TShape;
    Credits: TSegmentDisplay;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    noCollision: TCheckBox;
    Flame: TImage;
    FlameBack: TImage;
    FlameDown: TImage;
    FlameUp: TImage;
    CheatPanel: TPanel;
    noLaserHitsEnemy: TCheckBox;
    PicExplosion1: TImage;
    Instrument1: TNewShape;
    NewShape2: TNewShape;
    PicExplosion2: TImage;
    PicExplosion3: TImage;
    PicExplosion4: TImage;
    PicExplosion5: TImage;
    PicStar1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    PicBulletRed: TImage;
    PicBulletBlue: TImage;
    MeterFuel: TProgressBar;
    MeterWarpSpeed: TProgressBar;
    PicStar2: TImage;
    CollisionLamp: TShape;
    Score: TSegmentDisplay;
    Ship: TImage;
    PlayGround: TImage;
    Ship1: TImage;
    Ship2: TImage;
    TimerCollision: TTimer;
    TimerExplosion: TTimer;
    TimerHitFromEnemy: TTimer;
    TimerGameOver: TTimer;
    TimerOpening: TTimer;
    TimerGame: TTimer;
    TimerBackGround: TTimer;
    TimerSpecialObjects: TTimer;
    SpeedEnemies: TTrackBar;
    SpeedAndroids: TTrackBar;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TimerBackGroundTimer(Sender: TObject);
    procedure TimerCollisionStartTimer(Sender: TObject);
    procedure TimerCollisionTimer(Sender: TObject);
    procedure TimerExplosionTimer(Sender: TObject);
    procedure TimerGameOverStartTimer(Sender: TObject);
    procedure TimerGameOverTimer(Sender: TObject);
    procedure TimerGameTimer(Sender: TObject);
    procedure TimerHitFromEnemyStartTimer(Sender: TObject);
    procedure TimerHitFromEnemyTimer(Sender: TObject);
    procedure TimerOpeningStartTimer(Sender: TObject);
    procedure TimerOpeningTimer(Sender: TObject);
    procedure TimerSpecialObjectsTimer(Sender: TObject);
    Function CollisionDetection(Bullet, Target:TRect):boolean;
    Procedure EnemyFiring(Enemy:integer);
    Procedure ShowExplosion(rect:TRect);
  private
    TmpBMP:TBitmap;
    Background:array of string;
    BackgroundPics:array of TImage;
    StarPics:array of TImage;
    BackGroundPicFull, BackGroundPicOld, BackGroundPicNew:integer;
    PlayGroundLowerEnd:integer;
    SpecialObjects:array of TSpecialObject;
    strs: array[0..128] of HSTREAM;
    strc: Integer;
    Music:TMusic;
    SoundON:boolean;
    Shoot:array of TShoot;
    WarpSpeed, WarpSpeedMax, WarpSpeedMin:integer;
    StarFieldCount, StarfieldValue:integer;
    Enemies:array of TEnemy;
    EnemyShoot:array of TShoot;
    EnemyFireGO:boolean;
    EnemiesCount, EnemiesValue:integer;
    Asteroids:array of TImage;
    AsteroidsCount, AsteroidsValue:integer;
    GameStart, GameRunning:boolean;
    Explosion:array of TExplosion;
    Astronaut:TAstronaut;
    ShipStartPos:TRect;
    PfadPictures, PfadSounds:string;
    // Vektor Astronaut
    ShipStep:integer;
    TargetX, TargetY, TargetStep:integer;
    BeginX, BeginY:integer;
    SpaceCraft:TSpaceCraft;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.TimerBackGroundTimer(Sender: TObject);
Const
  Source_Y = 300;
var
  DestRect, SourceRect:TRect;
  SourceMaxX, SourceMaxY:integer;
  i, x, y, p, l, Overflow:integer;
  WarpSpecialObjects:double;
begin
    TmpBMP.Width:=WarpSpeed;
    TmpBMP.Height:=Source_Y;

    TimerBackGround.tag:=TimerBackGround.tag+1;
    SourceMaxX:=BackgroundPics[BackGroundPicOld].Picture.Bitmap.Width;
    SourceMaxY:=BackgroundPics[BackGroundPicOld].Picture.Bitmap.Height;
    DestRect.Top:=0;
    DestRect.Left:=0;
    DestRect.Bottom:=Source_Y;
    DestRect.Right:=WarpSpeed;
    // TimerBackGround.Tag läuft alle X-Pos des Original Bildes durch
    // Der Ausschnitt soll immer 500x300 sein und auf Dest Canavas gestrecht werden
    if TimerBackGround.tag >= SourceMaxX then
    begin
      TimerBackGround.tag:=0;
    end;
    If TimerBackGround.Tag <= (SourceMaxX-WarpSpeed) then
    begin
      // Einfach Ausschnitt kopieren
      SourceRect.Top:=0;
      SourceRect.Bottom:=SourceMaxY;
      SourceRect.Left:=TimerBackGround.tag;
      SourceRect.Right:=SourceRect.Left+WarpSpeed;
      TmpBMP.Canvas.CopyRect(DestRect, BackgroundPics[BackGroundPicOld].Picture.Bitmap.Canvas , SourceRect);
    end else
    begin
      // Rechts verbleibend und Folgendes von links
      Overflow:=TimerBackGround.Tag - (SourceMaxX-WarpSpeed);
      DestRect.Top:=0;
      DestRect.Bottom:=Source_Y;
      DestRect.Left:=0;
      DestRect.Right:=WarpSpeed-Overflow;
      SourceRect.Top:=0;
      SourceRect.Bottom:=SourceMaxY;
      SourceRect.Left:=TimerBackGround.tag;
      SourceRect.Right:=SourceMaxX;
      TmpBMP.Canvas.CopyRect(DestRect, BackgroundPics[BackGroundPicOld].Picture.Bitmap.Canvas, SourceRect);
      // Neues Bild, wenn "Ausschnitt links" am Ende von Bild
      if (TimerBackGround.tag+1) >= SourceMaxX then
      begin
        BackGroundPicOld:=BackGroundPicNew;
      end;

      // Neues Bild, Overflow=1
      if Overflow = 1 then
      begin
        if BackGroundPicNew < high(BackgroundPics) then
          inc(BackGroundPicNew)
        else
          BackGroundPicNew:=0;
      end;

      DestRect.Left:=WarpSpeed-Overflow;
      DestRect.Right:=WarpSpeed;
      SourceRect.Left:=0;
      SourceRect.Right:=Overflow;
      TmpBMP.Canvas.CopyRect(DestRect, BackgroundPics[BackGroundPicNew].Picture.Bitmap.Canvas, SourceRect);

    end;

    SourceRect.left:=0;
    SourceRect.Top:=0;
    SourceRect.Right:=WarpSpeed;
    SourceRect.Bottom:=Source_Y;
    PlayGround.Canvas.CopyRect(PlayGround.DestRect, TmpBMP.Canvas, SourceRect);

    // Special Objects
    WarpSpecialObjects:=(WarpSpeedMax-WarpSpeedMin-WarpSpeed)/100;

    for i := 0 to high(SpecialObjects) do
    begin
      SpecialObjects[i].pic.Transparent:=true;
      if SpecialObjects[i].active=true then
      begin
        if SpecialObjects[i].XSpeed > 0 then
        begin
          if (SpecialObjects[i].goX=1)and(SpecialObjects[i].XDirection=0) then
          begin
            SpecialObjects[i].pic.Left:=SpecialObjects[i].pic.Left-trunc(SpecialObjects[i].XSpeed*WarpSpecialObjects);
            if SpecialObjects[i].pic.Left < -SpecialObjects[i].pic.Width then
               SpecialObjects[i].active:=false;
          end else
          begin
            SpecialObjects[i].pic.Left:=SpecialObjects[i].pic.Left+trunc(SpecialObjects[i].XSpeed*WarpSpecialObjects);
            if SpecialObjects[i].pic.Left > Playground.Width then
               SpecialObjects[i].active:=false;
          end;
        end;

        if (SpecialObjects[i].goY=1)and(SpecialObjects[i].YSpeed > 0) then
        begin
          if SpecialObjects[i].YDirection=0 then
          begin
              SpecialObjects[i].pic.Top:=SpecialObjects[i].pic.Top-trunc(SpecialObjects[i].YSpeed*WarpSpecialObjects);
              if SpecialObjects[i].pic.Top < -SpecialObjects[i].pic.Height then
                 SpecialObjects[i].active:=false;
          end else
          begin
            SpecialObjects[i].pic.Top:=SpecialObjects[i].pic.Top+trunc(SpecialObjects[i].YSpeed*WarpSpecialObjects);
            if SpecialObjects[i].pic.Top > Playground.Height then
               SpecialObjects[i].active:=false;
          end;
        end;

          if (SpecialObjects[i].goZ=1)and(SpecialObjects[i].ZSpeed > 0) then
          begin
            // nur ins Unendliche abdriften, nicht nach vorne kommen!
            SpecialObjects[i].MoveCount:=SpecialObjects[i].MoveCount-SpecialObjects[i].ZSpeed;
            SpecialObjects[i].pic.Width:=trunc(SpecialObjects[i].MoveCount);
            SpecialObjects[i].pic.Height:=trunc(SpecialObjects[i].MoveCount);
            if SpecialObjects[i].pic.Width <= 1 then
               SpecialObjects[i].active:=false;
          end;
      end;
    end;

    // Move and Remove Stars
    for x := high(StarPics) downto 0 do
    begin
       StarPics[x].Left:=StarPics[x].Left-StarPics[x].tag;
       StarPics[x].Width:=StarPics[x].Height * (1+trunc(((WarpSpeedMax-WarpSpeedMin)-(WarpSpeed-WarpSpeedMin))/100));
       if StarPics[x].Left<-StarPics[x].Width then
       begin
        StarPics[x].Free;
        delete(StarPics, x, 1);
       end;
       StarPics[x].Invalidate;
    end;
end;

procedure TForm1.TimerCollisionStartTimer(Sender: TObject);
begin
  TimerCollision.Tag:=0;
end;

procedure TForm1.TimerCollisionTimer(Sender: TObject);
begin
  TimerCollision.tag:=TimerCollision.tag+1;
  if TimerCollision.tag=1 then
  begin
    BASS_ChannelPlay(strs[Music.Cheat1], True);
    CollisionLamp.Brush.Color:=cllime;
  end else
  begin
    if TimerCollision.tag >= 10 then
    begin
      TimerCollision.Enabled:=false;
      CollisionLamp.Brush.Color:=clmaroon;
    end;
  end;
end;

procedure TForm1.TimerExplosionTimer(Sender: TObject);
var
  y:integer;
begin
   for y := high(Explosion) downto 0 do
   begin
      Explosion[y].pic.BringToFront;
      Explosion[y].pic.Left:=Explosion[y].pic.Left-4;
      Explosion[y].count:=Explosion[y].count+1;
      if Explosion[y].count = 4 then
         Explosion[y].pic.Picture.Assign(PicExplosion2.Picture)
      else
      if Explosion[y].count = 8 then
         Explosion[y].pic.Picture.Assign(PicExplosion3.Picture)
      else
      if Explosion[y].count = 12 then
         Explosion[y].pic.Picture.Assign(PicExplosion4.Picture)
      else
      if Explosion[y].count = 16 then
         Explosion[y].pic.Picture.Assign(PicExplosion5.Picture)
      else
      if Explosion[y].count >= 22 then
      begin
        Explosion[y].pic.Visible:=false;
        Explosion[y].pic.free;
        delete(Explosion,y,1);
      end;
   end;
end;

procedure TForm1.TimerGameOverStartTimer(Sender: TObject);
begin
  TimerGameOver.tag:=0;
end;

procedure TForm1.TimerGameOverTimer(Sender: TObject);
var
  i, x, y, l, p, LeftEnd:integer;
begin
   LeftEnd:=-Ship.Width-200;
   if TimerGameOver.tag=0 then
   begin
     if Credits.tag>0 then
     begin
       Credits.tag:=Credits.tag-1;
       Credits.Text:=inttostr(Credits.tag);
     end;

     ShipStep:=5;
     TimerGameOver.tag:=TimerGameOver.tag+1;
     if fileexists(PfadPictures+'Astronautdown.png') then
        Astronaut.Image.Picture.LoadFromFile(PfadPictures+'Astronautdown.png');
     Ship.Picture.Assign(Ship2.Picture);
     BASS_ChannelStop(strs[Music.Enemey]);
     BASS_ChannelStop(strs[Music.Background]);
     BASS_ChannelPlay(strs[Music.Astronaut], True);
     //BASS_ChannelPlay(strs[Music.HumanNeutralised], True);
     //BASS_ChannelSetAttribute(strs[Music.HumanNeutralised], BASS_ATTRIB_VOL, 1.5);

     // Berechne Vektor für Astronaut
     Astronaut.ZoomMin:=4;
     Astronaut.ZoomMax:=trunc(Playground.Width/2);
     TargetX:=trunc((Playground.Width/100)*90);
     TargetY:=Playground.Height+200;
     TargetStep:= trunc((Ship.left - LeftEnd) / ShipStep);
     BeginX:=trunc(Ship.left+((Ship.Width/100)*20));
     BeginY:=trunc( Ship.top + ((Ship.Height/100)*20));
     Astronaut.ZoomFaktor:= (Astronaut.ZoomMax-Astronaut.ZoomMin)/TargetStep;
     Astronaut.ZoomCount:=Astronaut.ZoomMin;
     Astronaut.StepX := (TargetX-BeginX)/TargetStep;
     Astronaut.StepY := (TargetY-BeginY)/TargetStep;
     Astronaut.CountX:=BeginX;
     Astronaut.CountY:=BeginY;

     Astronaut.Image.Top:=trunc(Astronaut.CountY);
     Astronaut.Image.Width:=Astronaut.ZoomMin;
     Astronaut.Image.Height:=Astronaut.ZoomMin;
     Astronaut.Image.Left:=trunc(Astronaut.CountX);
     Astronaut.Image.Visible:=true;
     Astronaut.Image.BringToFront;
   end;

  if Ship.left > LeftEnd then
  begin
    if SoundON then
    begin
      l:=BASS_ChannelGetLength(strs[Music.Opening1],0);
      p:=BASS_ChannelGetPosition(strs[Music.Opening1],0);
      if (p=0)or(p > (l-10)) then
        BASS_ChannelPlay(strs[Music.Opening1], True);
    end;
    Ship.Left:=Ship.Left-ShipStep;

    Astronaut.CountX:=Astronaut.CountX+Astronaut.StepX;
    Astronaut.CountY:=Astronaut.CountY+Astronaut.StepY;
    Astronaut.ZoomCount:=Astronaut.ZoomCount+Astronaut.ZoomFaktor;

    Astronaut.Image.Width:=trunc(Astronaut.ZoomCount);
    Astronaut.Image.Height:=trunc(Astronaut.ZoomCount);
    Astronaut.Image.Top:=trunc(Astronaut.CountY);
    Astronaut.Image.Left:=trunc(Astronaut.CountX);
  end else
  begin
    WarpSpeed:=500;
    BASS_ChannelStop(strs[Music.Astronaut]);
    Astronaut.Image.Visible:=false;
    TimerGameOver.Enabled:=false;
    GameRunning:=false;
    l:=BASS_ChannelGetLength(strs[Music.GameOver],0);
    BASS_ChannelPlay(strs[Music.GameOver], True);
    repeat
      p:=BASS_ChannelGetPosition(strs[Music.GameOver],0);
    until (p > (l-10));
    // Remove Stars
    for x := high(StarPics) downto 0 do
    begin
      StarPics[x].Free;
      delete(StarPics, x, 1);
    end;
    // Remove Shoots
    for x := high(Shoot) downto 0 do
    begin
      Shoot[x].pic.Free;
      delete(Shoot, x, 1);
    end;
    // Remove EnemyShoots
    for x := high(EnemyShoot) downto 0 do
    begin
      EnemyShoot[x].pic.Free;
      delete(EnemyShoot, x, 1);
    end;
    // Remove Asteroids
    for x := high(Asteroids) downto 0 do
    begin
      Asteroids[x].Visible:=false;
    end;
    // Remove Enemies
    for x := high(Enemies) downto 0 do
    begin
      Enemies[x].pic.Visible:=false;
    end;
    if Credits.tag=0 then
    begin
      Label3.Visible:=true;
      BASS_ChannelPlay(strs[Music.Continue], True);
      BASS_ChannelSetAttribute(strs[Music.Continue], BASS_ATTRIB_VOL, 1.8);
    end else
    begin
      TimerOpening.Enabled:=true;
    end;
  end;

end;

procedure TForm1.TimerGameTimer(Sender: TObject);
var
  i, x, y, l, p  : integer;
  s:single;
  Sound:boolean;
  rect:TRect;
  Fire:boolean;
begin
    x:=Ship.left;
    y:=Ship.top;
    if GameStart=false then
    begin
      Sound:=false;
      // SpaceCraft LEFT
      if (GetKeyState(VK_LEFT) < 0) then
      begin
        if (Ship.left>(PlayGround.left +20)) then
        begin
          Ship.left := Ship.left - 8;
          if WarpSpeed < WarpSpeedMax then
            WarpSpeed:=WarpSpeed+10;
          FlameBack.Visible:=true;
        end else
        begin
          if WarpSpeed < WarpSpeedMax then
          begin
            FlameBack.Visible:=true;
            WarpSpeed:=WarpSpeed+10;
          end else
          begin
            FlameBack.Visible:=false;
          end;
        end;
        Sound:=FlameBack.Visible;
      end else
      begin
        FlameBack.Visible:=false;
      end;
      // SpaceCraft RIGHT
      if (GetKeyState(VK_RIGHT) < 0) then
      begin
        if (Ship.left<(PlayGround.left +PlayGround.width-20-Ship.Width)) then
        begin
          Ship.left := Ship.left + 8;
          if WarpSpeed > WarpSpeedMin then
             WarpSpeed:=WarpSpeed-10;
          Flame.Visible:=true;
        end else
        begin
          if WarpSpeed > WarpSpeedMin then
          begin
             Flame.Visible:=true;
             WarpSpeed:=WarpSpeed-10;
          end else
          begin
            Flame.Visible:=false;
          end;
        end;
        Sound:=Flame.Visible;
      end else
      begin
        Flame.Visible:=false;
      end;
      // SpaceCraft UP
      if (GetKeyState(VK_UP) < 0)and(Ship.top>=20) then
      begin
        Ship.top := Ship.top - 8;
        Sound:=true;
      end;
      // SpaceCraft DOWN
      if (GetKeyState(VK_DOWN) < 0)and(Ship.top<=(PlayGround.Height - Ship.Height - PlayGroundLowerEnd - 20)) then
      begin
        Ship.top := Ship.top + 8;
        Sound:=true;
      end;
      Flame.Left:=Ship.left-Flame.width+3;
      Flame.top:=Ship.top+trunc((Ship.Height-Flame.Height)/2);
      FlameUp.Left:=Ship.left+trunc(Ship.Width/4);
      FlameUp.top:=Ship.top+trunc(Ship.Height*0.83);
      FlameUp.Visible:=y>Ship.top;
      FlameDown.Left:=Ship.left+trunc(Ship.Width/4);
      FlameDown.top:=Ship.top+trunc(Ship.Height/4)-FlameDown.Height;
      FlameDown.Visible:=y<Ship.top;
      FlameBack.Left:=Ship.left+trunc(Ship.Width*0.36);
      FlameBack.top:=Ship.top+trunc(Ship.Height*0.458);
      FlameBack.BringToFront;
      MeterWarpSpeed.Position:=WarpSpeedMin+WarpSpeedMax-WarpSpeed;

      if Sound=true then
      begin
        if SoundON then
        begin
          l:=BASS_ChannelGetLength(strs[Music.ShipEngine],0);
          p:=BASS_ChannelGetPosition(strs[Music.ShipEngine],0);
          if (p=0)or(p > (l-10)) then
            BASS_ChannelPlay(strs[Music.ShipEngine], True);
        end;
      end else
      begin
        BASS_ChannelSetPosition(strs[Music.ShipEngine], 0, 0);
        BASS_ChannelStop(strs[Music.ShipEngine]);
        // StarCraft langsam zurückfallen lassen, wenn Max Warp
        if Ship.left > trunc((Playground.Width/100)*20)+3 then
           Ship.left:=Ship.left-5;
        if Ship.left < trunc((Playground.Width/100)*20)-3 then
          Ship.left:=Ship.left+5
      end;

    // Ship Fire
    for x := high(Shoot) downto 0 do
    begin
       shoot[x].pic.Left:=shoot[x].pic.Left+20;
       if shoot[x].pic.Left>Playground.Width then
       begin
        Shoot[x].pic.Free;
        Delete(Shoot, x, 1);
       end;
    end;


    Fire:=(GetKeyState(VK_SPACE) < 0);
    SpaceCraft.FireSpeedCount:=SpaceCraft.FireSpeedCount+1;

    if (SpaceCraft.FireSpeedCount>= SpaceCraft.FireSpeed) and (Fire=true) then
    begin
      Fire:=false;
      SpaceCraft.FireSpeedCount:=0;
      setlength(Shoot,high(Shoot)+2);
      Shoot[high(Shoot)].pic:=TImage.Create(nil);
      Shoot[high(Shoot)].pic.Parent:=Form1;
      Shoot[high(Shoot)].pic.Picture.Assign(PicBulletRed.Picture);
      Shoot[high(Shoot)].pic.Width:=PicBulletRed.Width;
      Shoot[high(Shoot)].pic.Height:=PicBulletRed.Height;
      //Shoot[high(Shoot)].pic.Stretch:=true;
      //Shoot[high(Shoot)].pic.Proportional:=true;
      Shoot[high(Shoot)].pic.Left:=Ship.Left+Ship.Width-20;
      Shoot[high(Shoot)].pic.Top:=Ship.Top+trunc((Ship.Height*0.5)+(PicBulletRed.Height/2));
      if SoundON then BASS_ChannelPlay(strs[Music.Shoot], True);
    end;
   end;

  // StarField Engine
  inc(StarFieldCount);
  if StarFieldCount > StarfieldValue then
  begin
     // a new Star is borne :-)
     StarfieldValue:=3+Random(10);
     StarFieldCount:=0;
     setlength(StarPics,high(StarPics)+2);
     StarPics[high(StarPics)]:=TImage.Create(nil);
     if Random(2) = 0 then
       StarPics[high(StarPics)].Picture.Assign(PicStar1.Picture)
     else
       StarPics[high(StarPics)].Picture.Assign(PicStar2.Picture);
     StarPics[high(StarPics)].Parent:=Form1;
     StarPics[high(StarPics)].width:=1+Random(4);
     StarPics[high(StarPics)].Height:=StarPics[high(StarPics)].width;
     StarPics[high(StarPics)].tag:=1+Random(5);
     StarPics[high(StarPics)].top:=StarPics[high(StarPics)].Height+Random(Playground.Height-StarPics[high(StarPics)].Height);
     StarPics[high(StarPics)].Left:=PlayGround.Width;
     StarPics[high(StarPics)].Stretch:=true;
     StarPics[high(StarPics)].Proportional:=false;
     StarPics[high(StarPics)].Visible:=true;
  end;

  if GameStart=false then
  begin
    // Asteroids
    inc(AsteroidsCount);
    if AsteroidsCount > AsteroidsValue then
    begin
      AsteroidsValue:=20+Random(200);
      AsteroidsCount:=0;
      repeat
        i:= Random(high(Asteroids)+1);
       until (y>high(Asteroids)+1)or(Asteroids[i].Visible=false);
       if Asteroids[i].Visible=false then
       begin
         Asteroids[i].Left:=Playground.Width;
         Asteroids[i].top:=random(Playground.Height-PlayGroundLowerEnd-Asteroids[i].Height);
         Asteroids[i].Tag:=2+random(10);
         Asteroids[i].Visible:=true;
       end;
    end;
    for x := 0 to high(Asteroids) do
    begin
      if Asteroids[x].Visible then
      begin
        Asteroids[x].Left:=Asteroids[x].Left-Asteroids[x].tag-SpeedAndroids.Position;
        if Asteroids[x].Left<-Asteroids[x].Width then
        begin
          Asteroids[x].visible:=false;
        end;
       end;
    end;
    // Enemy
    inc(EnemiesCount);
    if EnemiesCount > EnemiesValue then
    begin
      EnemiesValue:=50+Random(60);
      EnemiesCount:=0;
      repeat
        i:= Random(high(Enemies)+1);
       until (y>high(Enemies)+1)or(Enemies[i].Pic.Visible=false);
       if Enemies[i].Pic.Visible=false then
       begin
         Enemies[i].Pic.Left:=Playground.Width;
         Enemies[i].Pic.top:=random(Playground.Height-PlayGroundLowerEnd-Enemies[i].Pic.Height);
         Enemies[i].Pic.Tag:=10+random(10);
         Enemies[i].action:=1+random(2);
         Enemies[i].StepCountX:=Playground.Width;
         Enemies[i].StepCountY:=Enemies[i].pic.top;
         Enemies[i].StepX:=8+(Random(80)/10);
         Enemies[i].StepY:=0.6+(Random(30)/10);

         Enemies[i].StepX:=1+(Random(80)/10);
         Enemies[i].StepY:=0.6+(Random(30)/10);

         Enemies[i].direction:=ord(Ship.top > Enemies[i].pic.top);
         if Enemies[i].action in [1] then
         begin
            // bisschen genauer auf das SpaceShip zielen :-)
            Enemies[i].StepY:=((Random(10)+20)/100)+(Ship.top - (Enemies[i].pic.top-(Enemies[i].pic.Height/2)))/((Playground.Width-Ship.ReadBounds.Right)/Enemies[i].StepX);
         end;

         if Enemies[i].action in [2] then
         begin
           Enemies[i].amplitude:=20+random(60);
           Enemies[i].top:=Enemies[i].pic.top;
           Enemies[i].Count:=0;
           Enemies[i].CountDir:=0;
         end;

         if SoundON then BASS_ChannelPlay(strs[Music.Enemey], True);
         Enemies[i].pic.Visible:=true;
       end;
    end;
    for x := 0 to high(Enemies) do
    begin
      if Enemies[x].pic.Visible then
      begin
        Enemies[x].StepCountX:=Enemies[x].StepCountX-Enemies[x].StepX-SpeedEnemies.Position;
        Enemies[x].pic.Left:=trunc(Enemies[x].StepCountX);
        if Enemies[x].action = 1 then
        begin
          Enemies[x].StepCountY:=Enemies[x].StepCountY+Enemies[x].StepY;
          Enemies[x].pic.top:=trunc(Enemies[x].StepCountY);
        end else
        if Enemies[x].action = 2 then
        begin
          if (Enemies[x].CountDir=0)and(Enemies[x].Count < 1) then
            Enemies[x].Count:=Enemies[x].Count+0.1
          else
            Enemies[x].CountDir:=1;
          if (Enemies[x].CountDir=1)and(Enemies[x].Count > -1) then
          Enemies[x].Count:=Enemies[x].Count-0.1
          else
            Enemies[x].CountDir:=0;
          s:=sin(Enemies[x].Count);
          Enemies[x].StepCountY:=Enemies[x].StepCountY+((Enemies[x].direction*-1)*Enemies[x].StepY);
          Enemies[x].pic.top:=trunc(Enemies[x].StepCountY + (Enemies[x].amplitude * s));
        end;
        if Random(400) < 10 then
          EnemyFiring(x);
       end;
       if Enemies[x].pic.Left < -Enemies[x].pic.Width then
       begin
          Enemies[x].pic.visible:=false;
       end;
    end;

    // Enemy Fire
    for x := high(EnemyShoot) downto 0 do
    begin
       EnemyShoot[x].pic.Left:=EnemyShoot[x].pic.Left-20;
       if EnemyShoot[x].pic.ReadBounds.Right < 0 then
       begin
        EnemyShoot[x].pic.Free;
        Delete(EnemyShoot, x, 1);
        if SoundON then BASS_ChannelStop(strs[Music.Enemey]);
       end;
    end;

    for y := high(EnemyShoot) downto 0  do
    begin
      // Enemy Fire on Ship
      if CollisionDetection(EnemyShoot[y].pic.BoundsRect, Ship.BoundsRect) then
      begin
        if noLaserHitsEnemy.Checked=false then
        begin
         // Ohh NO, Game Over
         TimerGame.Enabled:=false;
         EnemyShoot[y].pic.Free;
         delete(EnemyShoot, y,1);
         Ship.tag:=0;
         rect:=Ship.BoundsRect;
         rect.Left:=Ship.BoundsRect.Right;
         rect.Right:=Ship.BoundsRect.Right+rect.Width;
         rect.Width:=rect.Height;
         ShowExplosion( rect);
         Flame.Visible:=false;
         FlameUp.Visible:=false;
         FlameDown.Visible:=false;
         FlameBack.Visible:=false;
         TimerGameOver.Enabled:=true;
         BASS_ChannelPlay(strs[Music.Explosion], True);
        end else
        begin
          //if TimerHitFromEnemy.Enabled=false then
          //begin
            EnemyShoot[y].pic.Free;
            delete(EnemyShoot, y,1);
            TimerHitFromEnemy.Enabled:=true;
        end;
      end;
    end;

    for x := 0 to high(Asteroids) do
    begin
      if Asteroids[x].Visible then
      begin
        for y := high(Shoot) downto 0  do
        begin
          // Gun Hits on Asteroids
          if CollisionDetection(Shoot[y].pic.BoundsRect, Asteroids[x].BoundsRect) then
          begin
            Shoot[y].pic.Free;
            delete(Shoot,y,1);
            if SoundON then BASS_ChannelPlay(strs[Music.Explosion], true);
            ShowExplosion( Asteroids[x].BoundsRect);
            Asteroids[x].Visible:=false;
            Score.Tag:=Score.Tag+Asteroids[x].Tag;
            Score.Text:=format('%0.4d',[Score.Tag]);
          end;
        end;
        // Asteroid on Ship
        if (CollisionDetection(Ship.BoundsRect, Asteroids[x].BoundsRect)) then
        begin
          if (noCollision.Checked=false)then
          begin
            // Ohh NO, Game Over
            TimerGame.Enabled:=false;
            Ship.tag:=0;
            rect:=Ship.BoundsRect;
            rect.Left:=Ship.BoundsRect.Right;
            rect.Right:=Ship.BoundsRect.Right+rect.Width;
            rect.Width:=rect.Height;
            ShowExplosion( rect);
            Flame.Visible:=false;
            FlameUp.Visible:=false;
            FlameDown.Visible:=false;
            FlameBack.Visible:=false;
            TimerGameOver.Enabled:=true;
            BASS_ChannelPlay(strs[Music.Explosion], True);
          end else
          begin
            BASS_ChannelPlay(strs[Music.Cheat1], True);
            TimerCollision.Enabled:=true;
          end;
        end;
      end;
    end;

    for x := 0 to high(Enemies) do
    begin
      if Enemies[x].pic.Visible then
      begin
        for y := high(Shoot) downto 0  do
        begin
          // Gun Hits on Enemy
          if CollisionDetection(Shoot[y].pic.BoundsRect, Enemies[x].Pic.BoundsRect) then
          begin
            Shoot[y].pic.Free;
            delete(Shoot,y,1);
            if SoundON then BASS_ChannelStop(strs[Music.Enemey]);
            if SoundON then BASS_ChannelPlay(strs[Music.Explosion], true);
            ShowExplosion( Enemies[x].pic.BoundsRect);
            Enemies[x].pic.Visible:=false;
            Score.Tag:=Score.Tag+Enemies[x].pic.Tag;
            Score.Text:=format('%0.4d',[Score.Tag]);
          end;
        end;
      end;
    end;
  end; // Game activ



  Ship.BringToFront;
  FlameBack.BringToFront;
end;

procedure TForm1.TimerHitFromEnemyStartTimer(Sender: TObject);
begin
   TimerHitFromEnemy.Tag:=0;
end;

procedure TForm1.TimerHitFromEnemyTimer(Sender: TObject);
begin
   TimerHitFromEnemy.tag:=TimerHitFromEnemy.tag+1;
   if TimerHitFromEnemy.tag=1 then
   begin
     BASS_ChannelPlay(strs[Music.Cheat1], True);
     CollisionLamp1.Brush.Color:=cllime;
   end else
   begin
     if TimerHitFromEnemy.tag >= 10 then
     begin
       TimerHitFromEnemy.Enabled:=false;
       CollisionLamp1.Brush.Color:=clmaroon;
     end;
   end;
end;

procedure TForm1.TimerOpeningStartTimer(Sender: TObject);
begin
   TimerOpening.tag:=0;
end;

Procedure TForm1.ShowExplosion(rect:TRect);
begin
   setlength(Explosion, high(Explosion)+2);
   Explosion[high(Explosion)].pic:=TImage.create(nil);
   Explosion[high(Explosion)].pic.Parent:=Form1;
   Explosion[high(Explosion)].pic.Picture.Assign(PicExplosion1.Picture);
   Explosion[high(Explosion)].pic.Transparent:=true;
   Explosion[high(Explosion)].pic.Enabled:=true;
   Explosion[high(Explosion)].pic.Stretch:=true;
   Explosion[high(Explosion)].pic.Proportional:=false;
   Explosion[high(Explosion)].pic.Center:=true;
   Explosion[high(Explosion)].pic.Visible:=true;
   Explosion[high(Explosion)].pic.Width:=rect.Width+30;
   Explosion[high(Explosion)].pic.Height:=rect.Height+30;
   Explosion[high(Explosion)].pic.Left:=rect.Left-15;
   Explosion[high(Explosion)].pic.Top:=rect.Top-15;
   Explosion[high(Explosion)].count:=0;
   Explosion[high(Explosion)].pic.BringToFront;
   Explosion[high(Explosion)].max:=3+Random(10);
end;

Procedure TForm1.EnemyFiring(Enemy:integer);
begin
  EnemyFireGO:=false;
  setlength(EnemyShoot,high(EnemyShoot)+2);
  EnemyShoot[high(EnemyShoot)].pic:=TImage.Create(nil);
  EnemyShoot[high(EnemyShoot)].pic.Parent:=Form1;
  EnemyShoot[high(EnemyShoot)].pic.Picture.Assign(PicBulletBlue.Picture);
  EnemyShoot[high(EnemyShoot)].pic.Width:=PicBulletBlue.Width;
  EnemyShoot[high(EnemyShoot)].pic.Height:=PicBulletBlue.Height;
  EnemyShoot[high(EnemyShoot)].pic.left:=Enemies[Enemy].Pic.Left-PicBulletBlue.Width;
  EnemyShoot[high(EnemyShoot)].pic.Top:=Enemies[Enemy].Pic.Top+trunc(Enemies[Enemy].Pic.Height/2)-trunc(PicBulletBlue.Height/2);
  EnemyShoot[high(EnemyShoot)].pic.Visible:=true;
  if SoundON then BASS_ChannelPlay(strs[Music.EnemyLaser], True);
end;



Function TForm1.CollisionDetection(Bullet, Target:TRect):boolean;
var
  BulletHotPoint:integer;
begin
  BulletHotPoint:=trunc(Bullet.top+(Bullet.Height/2));
//  Result:=(Bullet.Top >= Target.Top)and(Bullet.Bottom <= Target.Bottom)
  Result:=(BulletHotPoint >= Target.Top)and(BulletHotPoint <= Target.Bottom)
           and
          (Bullet.Right >= Target.Left)and (Bullet.Right <= Target.Right);
end;


procedure TForm1.TimerOpeningTimer(Sender: TObject);
var
  i:single;
begin
  if TimerOpening.tag=0 then
  begin
     ShipStep:=5;
     if Credits.tag = 0 then
     begin
       Credits.tag:=3;
     end;
     Credits.Text:=inttostr(Credits.tag);
     if fileexists(PfadPictures+'Astronautleft.png') then
        Astronaut.Image.Picture.LoadFromFile(PfadPictures+'Astronautleft.png');
     Label3.Visible:=false;
     TimerOpening.tag:=TimerOpening.tag+1;
     BASS_ChannelPlay(strs[Music.ShipEngine], true);
     TimerOpening.tag:=TimerOpening.tag+1;
     Ship.Picture.Assign(Ship1.Picture);
     Ship.left:=-Ship.Width-200;
     Ship.Top:=trunc((PlayGround.Height - Ship.Height - PlayGroundLowerEnd)/2);
     Ship.BringToFront;
     BASS_ChannelPlay(strs[Music.Astronaut], True);

     // Berechne Vektor für Astronaut
     TargetX:=trunc(((Playground.Width/100)*20)+((Ship.Width/100)*20));
     TargetY:=trunc( ((PlayGround.Height - PlayGroundLowerEnd)/2) + ((Ship.Height/100)*20));
     TargetStep:= trunc((ABS(Ship.left) + ((Playground.Width/100)*20)) / ShipStep);
     BeginX:=trunc((Playground.Width/100)*90);
     BeginY:=Playground.Height;
     Astronaut.ZoomMin:=4;
     Astronaut.ZoomMax:=trunc(Playground.Width/2);
     Astronaut.ZoomFaktor:= (Astronaut.ZoomMax-Astronaut.ZoomMin)/TargetStep;
     Astronaut.ZoomCount:=Astronaut.ZoomMax;
     Astronaut.StepX := (BeginX-TargetX)/TargetStep;
     Astronaut.StepY := (BeginY-TargetY)/TargetStep;
     Astronaut.CountX:=BeginX;
     Astronaut.CountY:=BeginY;

     Astronaut.Image.Top:=trunc(Astronaut.CountY);
     Astronaut.Image.Width:=Astronaut.ZoomMax;
     Astronaut.Image.Height:=Astronaut.ZoomMax;
     Astronaut.Image.Left:=trunc(Astronaut.CountX);
     Astronaut.Image.Visible:=true;
     Astronaut.Image.BringToFront;


     BASS_ChannelPlay(strs[Music.AstronautSpeech], True);
     BASS_ChannelSetAttribute(strs[Music.AstronautSpeech], BASS_ATTRIB_VOL, 1.5);
  end;
  if Credits.tag = 0 then
  begin
    if Score.Tag > 0 then
    begin
      Score.Tag:=0;
      Score.Text:=format('%0.4d',[Score.Tag]);
    end;
  end;
  if Ship.left < trunc((Playground.Width/100)*20)-3 then
  begin
    Astronaut.CountX:=Astronaut.CountX-Astronaut.StepX;
    Astronaut.CountY:=Astronaut.CountY-Astronaut.StepY;
    Astronaut.ZoomCount:=Astronaut.ZoomCount-Astronaut.ZoomFaktor;

    Astronaut.Image.Width:=trunc(Astronaut.ZoomCount);
    Astronaut.Image.Height:=trunc(Astronaut.ZoomCount);
    Astronaut.Image.Top:=trunc(Astronaut.CountY);
    Astronaut.Image.Left:=trunc(Astronaut.CountX);


    Ship.Top:=trunc((PlayGround.Height - Ship.Height - PlayGroundLowerEnd)/2);
    Ship.left:=Ship.left+ShipStep;
    Flame.Left:=Ship.left-Flame.width+3;
    Flame.top:=Ship.top+trunc((Ship.Height-Flame.Height)/2);
    Flame.visible:=true;
    if Ship.left > -Ship.Width then
    begin
      i:=(Ship.Left+Ship.Width)/((((Playground.Width/100)*20)+Ship.Width)/100);
      if SoundON then BASS_ChannelSetAttribute(strs[Music.Opening1], BASS_ATTRIB_VOL, (100-i)/100);
    end;
  end else
  begin
    TimerOpening.Enabled:=false;
    BASS_ChannelStop(strs[Music.Astronaut]);
    Astronaut.Image.Visible:=false;
    GameRunning:=true;
    if SoundON then
    begin
      BASS_ChannelStop(strs[Music.ShipEngine]);
      BASS_ChannelStop(strs[Music.Opening1]);
      BASS_ChannelSetPosition(strs[Music.Opening1],0,0);
      BASS_ChannelSetAttribute(strs[Music.ShipEngine], BASS_ATTRIB_VOL, 0.6);
      BASS_ChannelSetAttribute(strs[Music.Opening1], BASS_ATTRIB_VOL, 1);
      BASS_ChannelPlay(strs[Music.ThrottleUp], True);
      BASS_ChannelPlay(strs[Music.Background], True);
    end;
    Flame.visible:=false;
    GameStart:=false;
    TimerGame.Enabled:=true;
  end;
end;

procedure TForm1.TimerSpecialObjectsTimer(Sender: TObject);
var
  i, y:integer;
begin
   // "zufällig" Special Objekte starten
   if Random(5000) < TimerSpecialObjects.Interval then
   begin
     // zufälliges Object auswählen
     y:=0;
     repeat
       i:= random( high(SpecialObjects) +1);
       if SpecialObjects[i].active=false then
       begin
         SpecialObjects[i].ZSpeed:=Random(10);
         SpecialObjects[i].XDirection:=Random(2);
         SpecialObjects[i].YDirection:=Random(2);
         SpecialObjects[i].gox:=Random(2);
         SpecialObjects[i].goy:=Random(2);
         SpecialObjects[i].goZ:=Random(2);
         SpecialObjects[i].XSpeed:=1+Random(5);
         SpecialObjects[i].YSpeed:=1+Random(3);
         SpecialObjects[i].ZSpeed:=0.3+(Random(10)/10);
         if (SpecialObjects[i].XSpeed = 0)and(SpecialObjects[i].YSpeed=0) then
         begin
           SpecialObjects[i].XDirection:=1+Random(2);
           SpecialObjects[i].XSpeed:=1+Random(5);
         end;
         SpecialObjects[i].MoveCount:=0;

         if SpecialObjects[i].Xdirection=0 then
           SpecialObjects[i].pic.Left:=Playground.Width+1
         else
           SpecialObjects[i].pic.Left:=-SpecialObjects[i].pic.Width;

         if SpecialObjects[i].Ydirection=0 then
           SpecialObjects[i].pic.Top:=Playground.Height
         else
           SpecialObjects[i].pic.Top:=-SpecialObjects[i].pic.Height;
         SpecialObjects[i].pic.Width:=50+random(50);
         SpecialObjects[i].pic.Height:=SpecialObjects[i].pic.Width;
         SpecialObjects[i].MoveCount:=SpecialObjects[i].pic.Height;
         SpecialObjects[i].pic.Proportional:=true;
         SpecialObjects[i].pic.Stretch:=true;
         SpecialObjects[i].pic.Visible:=true;
         SpecialObjects[i].active:=true;
         y:=1000;
       end else
       begin
         inc(y);
       end;
     until y > (high(SpecialObjects) +1);
   end;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  i:integer;
begin
    TimerBackGround.Enabled:=false;
    setlength(StarPics,high(StarPics)+2);
    for i := 0 to high(StarPics) do
      StarPics[i].Free;
    setlength(StarPics,0);

    Astronaut.Image.free;

    for i := 0 to high(Enemies) do
      Enemies[i].Pic.Free;
    setlength(Enemies, 0);

    for i := 0 to high(BackgroundPics) do
      BackgroundPics[i].Free;
    setlength(BackgroundPics, 0);

    for i := 0 to high(Asteroids) do
      Asteroids[i].Free;
    setlength(Asteroids, 0);

    TimerSpecialObjects.Enabled:=false;
    for i := 0 to high(SpecialObjects) do
      SpecialObjects[i].pic.Free;
    setlength(SpecialObjects, 0);

    for i := 0 to high(EnemyShoot) do
      EnemyShoot[i].pic.Free;
    setlength(EnemyShoot, 0);

    for i := 0 to high(Shoot) do
      Shoot[i].pic.Free;
    setlength(Shoot, 0);


    TmpBMP.free;
end;


procedure TForm1.FormCreate(Sender: TObject);
var
  i:integer;
  s:single;
  ObjectPath:string;
  found:boolean;
  PascalFiles: TStringList;
  {$IFDEF LINUX}
  H:HWND;
  {$ENDIF}
begin
   TimerGame.enabled:=false;
   TimerBackGround.enabled:=false;
   TimerSpecialObjects.enabled:=false;
   GameStart:=true;
   Randomize();
   PfadPictures:=StringReplace(extractfilepath(application.ExeName)+'Assets\Pictures\','\',Pathdelim,[rfreplaceall]);
   PfadSounds:=StringReplace(extractfilepath(application.ExeName)+'Assets\Sound\','\',Pathdelim,[rfreplaceall]);

    TmpBMP:=TBitmap.Create;
    // Lade Backgrounds
    ObjectPath:=PfadPictures+'background';
    i:=1;
    setlength(BackgroundPics, 0);
    repeat
      found:=fileexists( ObjectPath+inttostr(i)+'.jpg');
      if found then
      begin
        setlength(BackgroundPics, high(BackgroundPics)+2);
        BackgroundPics[high(BackgroundPics)]:=TImage.create(Nil);
        BackgroundPics[high(BackgroundPics)].Visible:=false;
        BackgroundPics[high(BackgroundPics)].Picture.LoadFromFile(ObjectPath+inttostr(i)+'.jpg');
        inc(i);
      end;
    until found=false;

    if high(BackgroundPics) = -1 then
    begin
      BackGroundPicOld:=-1;
      BackGroundPicNew:=-1;
    end else
    if high(BackgroundPics) = 0 then
    begin
      BackGroundPicOld:=0;
      BackGroundPicNew:=-1;
    end else
    if high(BackgroundPics) >= 1 then
    begin
      BackGroundPicOld:=0;
      BackGroundPicNew:=1;
    end;
    BackGroundPicFull:=BackGroundPicOld;

    // Lade SpecialObjects
    ObjectPath:=PfadPictures+'Object';
    i:=1;
    setlength(SpecialObjects, 0);
    repeat
      found:=fileexists( ObjectPath+inttostr(i)+'.png');
      if found then
      begin
        setlength(SpecialObjects, high(SpecialObjects)+2);
        SpecialObjects[high(SpecialObjects)].pic:=TImage.create(nil);
        SpecialObjects[high(SpecialObjects)].pic.Parent:=Form1;
        SpecialObjects[high(SpecialObjects)].pic.Picture.LoadFromFile(ObjectPath+inttostr(i)+'.png');
        SpecialObjects[high(SpecialObjects)].pic.Transparent:=true;
        SpecialObjects[high(SpecialObjects)].pic.Enabled:=true;
        SpecialObjects[high(SpecialObjects)].pic.Stretch:=true;
        SpecialObjects[high(SpecialObjects)].pic.Proportional:=true;
        SpecialObjects[high(SpecialObjects)].pic.Center:=true;
        SpecialObjects[high(SpecialObjects)].pic.Visible:=false;
        SpecialObjects[high(SpecialObjects)].pic.Width:=50+Random(50);
        SpecialObjects[high(SpecialObjects)].pic.Height:=50+Random(50);
        SpecialObjects[high(SpecialObjects)].active:=false;
        inc(i);
      end;
    until found=false;

    // check the correct BASS was loaded
    if (HIWORD(BASS_GetVersion) <> BASSVERSION) then
    begin
    	Showmessage('An incorrect version of BASS.DLL was loaded');
    	Halt;
    end;

    // Initialize audio - default device, 44100hz, stereo, 16 bits
    {$IFDEF LINUX}
     if not BASS_Init(-1, 44100, 0, @H, nil) then
     	Showmessage('Error initializing audio!');
    {$ELSE}
    if not BASS_Init(-1, 44100, 0, Handle, nil) then
    	Showmessage('Error initializing audio!');
    {$ENDIF}

    strc := 0;		// stream count
    ObjectPath := PChar(PfadSounds+'ShipSound.mp3');
    strs[strc] := BASS_StreamCreateFile(False, PChar(ObjectPath), 0, 0, 0);
    Music.ShipEngine:=strc;
    inc(strc);
    ObjectPath := PChar(PfadSounds+'Laser3.mp3');
    strs[strc] := BASS_StreamCreateFile(False, PChar(ObjectPath), 0, 0, 0);
    Music.Shoot:=strc;
    inc(strc);
    ObjectPath := PChar(PfadSounds+'Background3.mp3');
    strs[strc] := BASS_StreamCreateFile(False, PChar(ObjectPath), 0, 0, BASS_MUSIC_LOOP );
    Music.Background:=strc;
    BASS_ChannelSetAttribute(strs[Music.Background], BASS_ATTRIB_VOL, 0.2);
    inc(strc);
    ObjectPath := PChar(PfadSounds+'Opening.mp3');
    strs[strc] := BASS_StreamCreateFile(False, PChar(ObjectPath), 0, 0, BASS_MUSIC_LOOP );
    Music.Opening1:=strc;
    inc(strc);
    ObjectPath := PChar(PfadSounds+'Explosion3.mp3');
    strs[strc] := BASS_StreamCreateFile(False, PChar(ObjectPath), 0, 0, 0 );
    Music.Explosion:=strc;
    inc(strc);
    ObjectPath := PChar(PfadSounds+'GameOver.wav');
    strs[strc] := BASS_StreamCreateFile(False, PChar(ObjectPath), 0, 0, 0 );
    Music.GameOver:=strc;
    inc(strc);
    ObjectPath := PChar(PfadSounds+'enemy.mp3');
    strs[strc] := BASS_StreamCreateFile(False, PChar(ObjectPath), 0, 0, 0 );
    Music.Enemey:=strc;
    inc(strc);
    ObjectPath := PChar(PfadSounds+'Laser4.mp3');
    strs[strc] := BASS_StreamCreateFile(False, PChar(ObjectPath), 0, 0, 0 );
    Music.EnemyLaser:=strc;
    inc(strc);
    ObjectPath := PChar(PfadSounds+'Astronaut.mp3');
    strs[strc] := BASS_StreamCreateFile(False, PChar(ObjectPath), 0, 0, 0 );
    Music.Astronaut:=strc;
    inc(strc);
    ObjectPath := PChar(PfadSounds+'Cheat1.mp3');
    strs[strc] := BASS_StreamCreateFile(False, PChar(ObjectPath), 0, 0, 0 );
    Music.Cheat1:=strc;
    inc(strc);
    ObjectPath := PChar(PfadSounds+'HumanNeutralised.mp3');
    strs[strc] := BASS_StreamCreateFile(False, PChar(ObjectPath), 0, 0, 0 );
    Music.HumanNeutralised:=strc;
    inc(strc);
    ObjectPath := PChar(PfadSounds+'Continue.mp3');
    strs[strc] := BASS_StreamCreateFile(False, PChar(ObjectPath), 0, 0, 0 );
    Music.Continue:=strc;
    inc(strc);
    ObjectPath := PChar(PfadSounds+'AstronautSpeech.mp3');
    strs[strc] := BASS_StreamCreateFile(False, PChar(ObjectPath), 0, 0, 0 );
    Music.AstronautSpeech:=strc;
    inc(strc);
    ObjectPath := PChar(PfadSounds+'ThrottleUp.mp3');
    strs[strc] := BASS_StreamCreateFile(False, PChar(ObjectPath), 0, 0, 0 );
    Music.ThrottleUp:=strc;

    // Loading Asteroids
    try
      PascalFiles := TStringList.Create;
      FindAllFiles(PascalFiles, PfadPictures, 'Asteroids*', true);
      setlength(Asteroids, 0);
      for i := 1 to PascalFiles.Count do
      begin
        setlength(Asteroids, high(Asteroids)+2);
        Asteroids[high(Asteroids)]:=TImage.create(nil);
        Asteroids[high(Asteroids)].Parent:=Form1;
        Asteroids[high(Asteroids)].Picture.LoadFromFile(PascalFiles[i-1]);
        Asteroids[high(Asteroids)].Transparent:=true;
        Asteroids[high(Asteroids)].Enabled:=true;
        Asteroids[high(Asteroids)].Stretch:=true;
        Asteroids[high(Asteroids)].Proportional:=true;
        Asteroids[high(Asteroids)].Center:=true;
        Asteroids[high(Asteroids)].Visible:=false;
        Asteroids[high(Asteroids)].Width:=50+Random(50);
        Asteroids[high(Asteroids)].Height:=50+Random(50);
        Asteroids[high(Asteroids)].Tag:=20; // Score
      end;
    finally
      PascalFiles.Free;
    end;

    // Loading Enemies
    try
      PascalFiles := TStringList.Create;
      FindAllFiles(PascalFiles, PfadPictures, 'Enemy*', true);
      setlength(Enemies, 0);
      for i := 1 to PascalFiles.Count do
      begin
        setlength(Enemies, high(Enemies)+2);
        Enemies[high(Enemies)].Pic:=TImage.create(nil);
        Enemies[high(Enemies)].Pic.Parent:=Form1;
        Enemies[high(Enemies)].Pic.Picture.LoadFromFile(PascalFiles[i-1]);
        Enemies[high(Enemies)].Pic.Transparent:=true;
        Enemies[high(Enemies)].Pic.Enabled:=true;
        Enemies[high(Enemies)].Pic.Stretch:=true;
        Enemies[high(Enemies)].Pic.Proportional:=true;
        Enemies[high(Enemies)].Pic.Center:=true;
        Enemies[high(Enemies)].Pic.Visible:=false;
        Enemies[high(Enemies)].Pic.Width:=50+Random(50);
        Enemies[high(Enemies)].Pic.Height:=50+Random(50);
        Enemies[high(Enemies)].Pic.Tag:=20;
      end;
    finally
      PascalFiles.Free;
    end;

    if fileexists( PfadPictures+'Astronautleft.png') then
    begin
      Astronaut.Image:=TImage.Create(nil);
      Astronaut.Image.Parent:=Form1;
      Astronaut.Image.AutoSize:=false;
      Astronaut.Image.Stretch:=true;
      Astronaut.Image.Proportional:=true;
      Astronaut.Image.BringToFront;
      Astronaut.Image.Picture.LoadFromFile(PfadPictures+'Astronautleft.png');
      Astronaut.Image.Left:=Playground.Width;
      Astronaut.Image.Top:=Playground.Height;
      Astronaut.Image.Width:=600;
      Astronaut.Image.Height:=600;
    end;

    PlayGroundLowerEnd:=Instrument1.Height;
    ShipStartPos.Left:=trunc((Playground.Width/100)*20)-3;
    ShipStartPos.Top:=(PlayGround.Height - trunc(Ship.Height/2) - PlayGroundLowerEnd);
    Ship.Top:=(PlayGround.Height - trunc(Ship.Height/2) - PlayGroundLowerEnd);
    Ship.Width:=trunc(PlayGround.Width/9);
    Ship.Height:=trunc(Ship.Width/2.3);
    Ship.BringToFront;
    Ship.left:=-Ship.Width-200;
    SpaceCraft.SpeedUp:=10;
    SpaceCraft.SpeedDown:=10;
    SpaceCraft.SpeedLeft:=10;
    SpaceCraft.Speedright:=10;
    SpaceCraft.FireSpeed:=8; // lower is faster  per Tick ~40ms Delay
    Flame.Width:=trunc(Ship.Width*0.3);
    Flame.Height:=trunc(Ship.Height*0.375);
    Flame.Left:=Ship.left+Flame.width;
    Flame.BringToFront;
    FlameUp.Width:=trunc(Ship.Width/6.88);
    FlameUp.Height:=trunc(Ship.Height/4);
    FlameDown.Width:=trunc(Ship.Width/6.88);
    FlameDown.Height:=trunc(Ship.Height/4);
    FlameBack.Width:=trunc(Ship.Width/9.1);
    FlameBack.Height:=trunc(Ship.Height/3);
    Flame.Visible:=false;
    FlameUp.Visible:=false;
    FlameDown.Visible:=false;
    FlameBack.Visible:=false;
    WarpSpeed:=500;
    WarpSpeedMax:=800;
    WarpSpeedMin:=80;
    MeterWarpSpeed.Max:=WarpSpeedMax;
    MeterWarpSpeed.Min:=WarpSpeedMin;
    SoundON:=true;
    if SoundON then BASS_ChannelPlay(strs[Music.Opening1], True);

    BASS_ChannelPlay(strs[Music.ShipEngine], True);
    BASS_ChannelSetAttribute(strs[Music.ShipEngine], BASS_ATTRIB_VOL, 0.6);

    GameStart:=true;
    GameRunning:=false;
    TimerGame.enabled:=true;
    TimerBackGround.enabled:=true;
    TimerSpecialObjects.enabled:=true;
    TimerOpening.enabled:=true;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
   // Cheat Mode
   if (key = ord('C')) then
   begin
     CheatPanel.top:=Playground.Height-CheatPanel.Height;
     CheatPanel.Visible:=not CheatPanel.Visible;
   end else
   if GameRunning=true then
   begin
    //if (GameStart=false)and(key = VK_SPACE) then
    //  Fire:=true;
   end else
   begin
     if Key = VK_ESCAPE then
     begin
       close;
     end else
     begin
       TimerOpening.Enabled:=true;
     end;
   end;

end;


end.


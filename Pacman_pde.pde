int TILE=32;
int COLS=19;
int ROWS=21;

char[][] map;

Pacman pacman;

Ghost blinky,pinky,inky,clyde;
ArrayList<Ghost> ghosts=new ArrayList<Ghost>();

ArrayList<PVector> pellets=new ArrayList<PVector>();
ArrayList<PVector> powerPellets=new ArrayList<PVector>();

int score=0;
int lives=3;

boolean frightened=false;
int frightenedTimer=0;

boolean dying=false;
float deathAnim=0;

boolean gameOver=false;

float PAC_SPEED=2.4;
float GHOST_SPEED=1.7;

boolean ready=true;
int readyTimer=120;

void settings(){
size(COLS*TILE,ROWS*TILE);
}

void setup(){
startGame();
}

void startGame(){

pellets.clear();
powerPellets.clear();
ghosts.clear();

score=0;
lives=3;
gameOver=false;

loadMap();

ready=true;
readyTimer=120;

}

void draw(){

background(0);

if(gameOver){

drawMap();
drawPellets();

fill(255,0,0);
textAlign(CENTER);
textSize(50);
text("GAME OVER",width/2,height/2);

fill(255);
textSize(20);
text("Click to restart",width/2,height/2+40);

return;
}

if(ready){

drawMap();
drawPellets();

pacman.draw();
for(Ghost g:ghosts) g.draw();

fill(255,255,0);
textAlign(CENTER);
textSize(40);
text("READY!",width/2,height/2);

readyTimer--;

if(readyTimer<=0) ready=false;

return;
}

if(!dying){

pacman.update();

for(Ghost g:ghosts){
g.update();
}

}

if(frightened){

frightenedTimer--;

if(frightenedTimer<=0){
frightened=false;
for(Ghost g:ghosts) g.frightened=false;
}

}

drawMap();
drawPellets();

pacman.draw();

for(Ghost g:ghosts) g.draw();

fill(255);
textAlign(LEFT);
textSize(18);
text("Score: "+score,10,20);
text("Lives: "+lives,width-100,20);

drawLives();

if(dying){

deathAnim++;

if(deathAnim>60){

lives--;

if(lives<=0){
gameOver=true;
return;
}

resetPositions();
dying=false;

}

}

}

void mousePressed(){

if(gameOver){
startGame();
}

}

void drawLives(){

for(int i=0;i<lives;i++){
fill(255,255,0);
arc(20+i*30,height-20,20,20,0,TWO_PI);
}

}

void triggerFrightened(){

frightened=true;
frightenedTimer=480;

for(Ghost g:ghosts){
g.frightened=true;
}

}

void startDeath(){

if(dying) return;

dying=true;
deathAnim=0;

}

void resetPositions(){

pacman.reset();

for(Ghost g:ghosts){
g.reset();
}

ready=true;
readyTimer=120;

}

boolean wall(int c,int r){

if(c<0||r<0||c>=COLS||r>=ROWS) return true;

return map[r][c]=='X';

}

void drawMap(){

fill(0,0,255);

for(int r=0;r<ROWS;r++)
for(int c=0;c<COLS;c++)
if(map[r][c]=='X')
rect(c*TILE,r*TILE,TILE,TILE);

}

void drawPellets(){

fill(255);

for(PVector p:pellets)
ellipse(p.x,p.y,6,6);

for(PVector p:powerPellets)
ellipse(p.x,p.y,12,12);

}

void loadMap(){

String[] raw={

"XXXXXXXXXXXXXXXXXXX",
"X........X........X",
"X.XX.XXX.X.XXX.XX.X",
"XO...............OX",
"X.XX.X.XXXXX.X.XX.X",
"X....X...X...X....X",
"XXXX.XXX   XXX.XXXX",
"   X.X       X.X   ",
"XXXX.X XXrXX X.XXXX",
"     .  bpo  .     ",
"XXXX.X XXXXX X.XXXX",
"   X.X       X.X   ",
"XXXX.X XXXXX X.XXXX",
"X........X........X",
"X.XX.XXX.X.XXX.XX.X",
"X..X....P....X....X",
"XX.X.X.XXXXX.X.X.XX",
"X....X...X...X....X",
"X.XXXXXX.X.XXXXXX.X",
"XO...............OX",
"XXXXXXXXXXXXXXXXXXX"

};

map=new char[ROWS][COLS];

for(int r=0;r<ROWS;r++){
for(int c=0;c<COLS;c++){

char t=raw[r].charAt(c);
map[r][c]=t;

float px=c*TILE+TILE/2;
float py=r*TILE+TILE/2;

if(t=='P') pacman=new Pacman(c,r);
if(t=='.') pellets.add(new PVector(px,py));
if(t=='O') powerPellets.add(new PVector(px,py));

if(t=='r') blinky=new Ghost(c,r,"blinky");
if(t=='p') pinky=new Ghost(c,r,"pinky");
if(t=='b') inky=new Ghost(c,r,"inky");
if(t=='o') clyde=new Ghost(c,r,"clyde");

}
}

ghosts.add(blinky);
ghosts.add(pinky);
ghosts.add(inky);
ghosts.add(clyde);

}

class Pacman{

float x,y;

int dirX=-1,dirY=0;
int nextX=0,nextY=0;

float mouth=0;

Pacman(int c,int r){
x=c*TILE+TILE/2;
y=r*TILE+TILE/2;
}

void reset(){
x=9*TILE+TILE/2;
y=15*TILE+TILE/2;
dirX=-1;
dirY=0;
}

void update(){

int c=int(x/TILE);
int r=int(y/TILE);

if(centered()){

if(!wall(c+nextX,r+nextY)){
dirX=nextX;
dirY=nextY;
}

if(wall(c+dirX,r+dirY)){
dirX=0;
dirY=0;
}

}

x+=dirX*PAC_SPEED;
y+=dirY*PAC_SPEED;

warp();

mouth+=0.15;

eatPellets();

}

void warp(){

int row=int(y/TILE);
int col=int(x/TILE);

if(row==9){

if(col<=0 && dirX==-1)
x=(COLS-1)*TILE+TILE/2;

if(col>=COLS-1 && dirX==1)
x=TILE/2;

}

}

boolean centered(){
return abs((x%TILE)-TILE/2)<2 && abs((y%TILE)-TILE/2)<2;
}

void eatPellets(){

for(int i=pellets.size()-1;i>=0;i--){
PVector p=pellets.get(i);
if(dist(x,y,p.x,p.y)<10){
pellets.remove(i);
score+=10;
}
}

for(int i=powerPellets.size()-1;i>=0;i--){
PVector p=powerPellets.get(i);
if(dist(x,y,p.x,p.y)<12){
powerPellets.remove(i);
score+=50;
triggerFrightened();
}
}

}

void draw(){

pushMatrix();
translate(x,y);

float rot=0;

if(dirX==1) rot=0;
if(dirX==-1) rot=PI;
if(dirY==1) rot=HALF_PI;
if(dirY==-1) rot=-HALF_PI;

rotate(rot);

fill(255,255,0);

if(dying){

float a=map(deathAnim,0,60,0,PI);
arc(0,0,28,28,a,TWO_PI-a);

}else{

float m=abs(sin(mouth))*PI/4;
arc(0,0,28,28,m,TWO_PI-m);

}

popMatrix();

}

}

class Ghost{

float x,y;

int dirX=1,dirY=0;

boolean frightened=false;
boolean eyes=false;

String type;

Ghost(int c,int r,String t){
x=c*TILE+TILE/2;
y=r*TILE+TILE/2;
type=t;
}

void reset(){

eyes=false;
frightened=false;

if(type.equals("blinky")){
x=9*TILE+TILE/2;
y=8*TILE+TILE/2;
}

if(type.equals("pinky")){
x=8*TILE+TILE/2;
y=9*TILE+TILE/2;
}

if(type.equals("inky")){
x=9*TILE+TILE/2;
y=9*TILE+TILE/2;
}

if(type.equals("clyde")){
x=10*TILE+TILE/2;
y=9*TILE+TILE/2;
}

}

void update(){

if(eyes){
goHome();
return;
}

int c=int(x/TILE);
int r=int(y/TILE);

if(centered()){
chooseDir(c,r);
}

float speed=frightened?1.3:GHOST_SPEED;

x+=dirX*speed;
y+=dirY*speed;

warp();

checkPacman();

}

void warp(){

int row=int(y/TILE);
int col=int(x/TILE);

if(row==9){

if(col<=0 && dirX==-1)
x=(COLS-1)*TILE+TILE/2;

if(col>=COLS-1 && dirX==1)
x=TILE/2;

}

}

void goHome(){

int c=int(x/TILE);
int r=int(y/TILE);

PVector target=new PVector(9,9);

if(centered())
chooseDir(c,r,target);

x+=dirX*2;
y+=dirY*2;

warp();

if(c==9 && r==9)
reset();

}

boolean centered(){
return abs((x%TILE)-TILE/2)<2 && abs((y%TILE)-TILE/2)<2;
}

void chooseDir(int c,int r){
chooseDir(c,r,new PVector(pacman.x/TILE,pacman.y/TILE));
}

void chooseDir(int c,int r,PVector target){

ArrayList<PVector> dirs=new ArrayList<PVector>();

if(!wall(c+1,r)&&dirX!=-1) dirs.add(new PVector(1,0));
if(!wall(c-1,r)&&dirX!=1) dirs.add(new PVector(-1,0));
if(!wall(c,r+1)&&dirY!=-1) dirs.add(new PVector(0,1));
if(!wall(c,r-1)&&dirY!=1) dirs.add(new PVector(0,-1));

PVector best=null;
float bestDist=999999;

for(PVector d:dirs){

float tx=c+d.x;
float ty=r+d.y;

float dist=dist(tx,ty,target.x,target.y);

if(dist<bestDist){
bestDist=dist;
best=d;
}

}

if(best!=null){
dirX=int(best.x);
dirY=int(best.y);
}

}

void checkPacman(){

if(dying) return;

if(dist(x,y,pacman.x,pacman.y)<16){

if(frightened){
score+=200;
eyes=true;
frightened=false;
}else{
startDeath();
}

}

}

void draw(){

boolean flash=false;

if(frightened && frightenedTimer<150){
if((frightenedTimer/10)%2==0) flash=true;
}

if(eyes){

fill(255);
ellipse(x-6,y-4,6,6);
ellipse(x+6,y-4,6,6);

fill(0);
ellipse(x-6,y-4,3,3);
ellipse(x+6,y-4,3,3);

return;

}

if(frightened){

if(flash) fill(255);
else fill(0,0,255);

}else{

if(type.equals("blinky")) fill(255,0,0);
if(type.equals("pinky")) fill(255,105,180);
if(type.equals("inky")) fill(0,255,255);
if(type.equals("clyde")) fill(255,165,0);

}

rect(x-16,y,32,16);
arc(x,y,32,32,PI,TWO_PI);

fill(255);
ellipse(x-6,y-4,6,6);
ellipse(x+6,y-4,6,6);

}

}

void keyPressed(){

if(keyCode==UP){pacman.nextX=0;pacman.nextY=-1;}
if(keyCode==DOWN){pacman.nextX=0;pacman.nextY=1;}
if(keyCode==LEFT){pacman.nextX=-1;pacman.nextY=0;}
if(keyCode==RIGHT){pacman.nextX=1;pacman.nextY=0;}

}

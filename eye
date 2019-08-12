int EYE_NODE = 5;
int EYE_EDGE = 8;
PVector[][] eyeL_pt = new PVector[EYE_NODE][EYE_EDGE];
PVector[][] eyeR_pt = new PVector[EYE_NODE][EYE_EDGE];
PVector eyeL_center;
PVector eyeR_center;

void setup(){
  size(500, 500, P3D); 
  noLoop();
  frameRate(2);
}

void draw(){
  background(200);
  pushMatrix();
  translate(width/2,height/2);
  strokeWeight(5);

  eye_make();
 
  //rotateX(PI/2);
  //rotateY(PI/2);  
  popMatrix();  
}

void eye_make(){
  float r = 50;
  float rotZ = -PI/16;
  float rotX = PI/4;

  
  for(int i=0; i<EYE_NODE; i++){  
      float thick = 35*i; 
      stroke(255,0,0);
      PVector end = new PVector(thick*sin(rotZ)*cos(rotX), thick*sin(rotZ)*sin(rotX), thick*cos(rotZ)); 
      point(end.x, end.y, end.z);
      for(int j=0;j<EYE_EDGE;j++){


        float plot = j * TWO_PI/EYE_EDGE;
        float x = r * sin(plot) * sin(rotZ);
        float z = r * cos(plot) * cos(rotX);
        float y = (r*sin(plot)*cos(rotZ)) + (r*cos(plot)*sin(rotX));
        eyeL_pt[i][j] = new PVector(x,y,z);
        stroke(0,0,0);
        point(x,y,z);
      }
  }
  
  /*
  beginShape(TRIANGLE_STRIP);
  for(int i=0; i<EYE_NODE; i++){
    for(int j=0; j<EYE_EDGE; j++){
      if(i!=EYE_NODE-1){
        vertex(eyeL_pt[i][j].x,eyeL_pt[i][j].y,eyeL_pt[i][j].z);
        vertex(eyeL_pt[i+1][j].x,eyeL_pt[i+1][j].y,eyeL_pt[i+1][j].z);
      }
    }
  }
  endShape(CLOSE);
  */
  

}

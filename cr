// ページの読み込みを待つ
window.addEventListener('load', init);

function init() {

  ////////////////画面設定

  // サイズを指定
  const width = 800;
  const height = 400;

  // レンダラーを作成
  let renderer = new THREE.WebGLRenderer({
        canvas: document.querySelector('#myCanvas')
      });

  renderer.setClearColor(new THREE.Color('grey'));//背景色の設定
  document.body.appendChild( renderer.domElement );
  renderer.setSize(width, height);

  // シーンを作成
  let scene = new THREE.Scene();

  // カメラを作成
  let camera = new THREE.PerspectiveCamera(45, width / height);
  camera.position.set(0, 0, 300);
  camera.lookAt(new THREE.Vector3(0, 0, 0));

  //ライト
  const light = new THREE.DirectionalLight( 0xffffff );
  light.position.set( 0, 10, 280 );
  scene.add( light );


  let ambLight = 1;
  const envlight = new THREE.AmbientLight(0xffffff, ambLight);
  scene.add(envlight);




/////////////////////////////////////////////////////////////////

  //共通def
  const NUM_POS = 3;
  const VER_RECT = NUM_POS * 4;
  const PI = Math.PI;
  const CLOSE = false;
  const OPEN = true;
  const LEFT = false;
  const RIGHT = true;

  //pipe
  let pipeRad = 0;
  let lowerPipePos = new THREE.Vector2();

  const reso = 6;
  const headNode = 4 * reso;
  const headEdge = 3 * reso;
  const pipeEdge = 2 * reso;
  const pipeNode = 2 * reso;
  const bodyNode = 2 * reso;
  const bodyEdge = 2 * reso; //4の倍数

  //size
  const wScale = 130;
  const armLength = wScale/10;
  const armLength2 = armLength * 1.2;
  const armThick = wScale/17;
  const footLength = wScale/8;
  const footLength2 = footLength * 1.5;
  const footThick = wScale/17;
  const headSize = wScale/1.2;
  const bodyLength = wScale/3.9;
  const bodyWidth = wScale/4;
  const ankleThick = footThick * Math.cos(PI/3.8);
  let upperArmThick = new Array(pipeNode);
  let lowerArmThick = new Array(pipeNode);
  let lowerArmWidth = new Array(pipeNode);
  let upperFootThick = new Array(pipeNode);
  let lowerFootThick = new Array(pipeNode);
  let lowerFootWidth = new Array(pipeNode);
  let bodyWidths = new Array(bodyNode);
  let bodyThicks = new Array(bodyNode);

  //Color
  const skinCol = new THREE.Color(0xe0a080);
  //const hairCol = new THREE.Color(0x5e270e);
  const hairCol = new THREE.Color(0x8b0000);
  //const eyeCol = new THREE.Color(0x38180f);
  const eyeCol = new THREE.Color(0xffd700);
  const highCol = new THREE.Color(0x38180f);
  //const bodyCol = new THREE.Color(0x8a4310);
  const bodyCol = new THREE.Color(0x000000);
  const stripeCol = new THREE.Color(0xcb9b8f);

  //materials
  const mono_vert = document.getElementById('vs_mono').textContent;
  const mono_frag = document.getElementById('fs_mono').textContent;
  const uv_vert = document.getElementById('vs_uv').textContent;
  const uv_frag = document.getElementById('fs_uv').textContent;
  const bi_frag = document.getElementById('fs_bi').textContent;
  const tri_frag = document.getElementById('fs_tri').textContent;

  let uniform = THREE.UniformsUtils.merge([
    THREE.UniformsLib['lights'],{
    'uTexture': { value: null },
    'uTone': { value: null },
    'uColor1': { value: null },
    'uColor2': { value: null },
    'uAmbient': { vale: ambLight}}
  ] );

  let material = new THREE.ShaderMaterial({
    side:THREE.DoubleSide,
    uniforms: uniform,
    vertexShader: null,
    fragmentShader: null,
    lights: true
  });

  let skinMat = material.clone();
  skinMat.vertexShader = mono_vert;
  skinMat.fragmentShader = mono_frag;
  skinMat.uniforms.uColor1.value = skinCol;

  let bodyMat = material.clone();
  bodyMat.vertexShader = mono_vert;
  bodyMat.fragmentShader = mono_frag;
  bodyMat.uniforms.uColor1.value = bodyCol;

  let hairMat = material.clone();
  hairMat.vertexShader = mono_vert;
  hairMat.fragmentShader = mono_frag;
  hairMat.uniforms.uColor1.value = hairCol;

  let eyeMat = material.clone();
  const loader = new THREE.TextureLoader();
  const eyeTex1 = loader.load('img/eye_open.png');
  const eyeTex2 = loader.load('img/eye_close.png');


  //geometry
  let upperArmGeoL;
  let upperArmGeoR;
  let jointArmGeoL;
  let jointArmGeoR;
  let lowerArmGeoL;
  let lowerArmGeoR;
  let bodyGeo;
  let upperFootGeoL;
  let upperFootGeoR;
  let jointFootGeoL;
  let jointFootGeoR;
  let ankleGeoL;
  let ankleGeoR;
  let lowerFootGeoL;
  let lowerFootGeoR;


  let eyelashObj;

  //groups
  //arms
  let handGL = new THREE.Group();
  let handGR = new THREE.Group();
  let elbowGL = new THREE.Group();
  let elbowGR = new THREE.Group();
  let lowerArmGL = new THREE.Group();
  let lowerArmGR = new THREE.Group();
  let armGL = new THREE.Group();
  let armGR = new THREE.Group();
  let armG = new THREE.Group();
  //head
  let headG = new THREE.Group();
  //body
  let bodyG = new THREE.Group();
  //feet
  let toeGL = new THREE.Group();
  let toeGR = new THREE.Group();
  let kneeGL = new THREE.Group();
  let kneeGR = new THREE.Group();
  let lowerFootGL = new THREE.Group();
  let lowerFootGR = new THREE.Group();
  let footGL = new THREE.Group();
  let footGR = new THREE.Group();
  let footG = new THREE.Group();



  ///////////////////////////////////////inits


  //headInit();
  //scene.add(headG);
  //makeGlass();
  //headG.rotation.y = PI/8;

  //armInit();
  //armUpdate(LEFT, 0.0,0.0,0,0); //-1-2, 0-1.5
  //armUpdate(RIGHT, 0.0,0,0,0);

  //bodyInit();
  //bodyUpdate(0,0,0); //-1-1, -1-1.5, -1,1
  //
  //bodyG.position.y = -50;
  //bodyG.rotation.y = PI/4;
  footInit();
  //footUpdate(LEFT, 1,1,0,0);
  //footUpdate(RIGHT, 1,1,0,0);



  let n = 0;
  let ot = 0;
  let bt = 0;
  let eye = OPEN;
  //animate();
  render();

  function animate(){
        n += 0.05;
        ot += 1;
        let v = Math.sin(n);
        if(ot==150){
          eye = CLOSE;
          blink(eye);
          ot = 0;
        }
        if(eye==CLOSE){
          bt += 1;
        }
        if(bt>8){
          eye = OPEN;
          blink(eye);
          bt = 0;
        }

        bodyUpdate(Math.sin(n), 0, 0);

        renderer.render( scene, camera );
        requestAnimationFrame( animate );

  }


  function render(){
      requestAnimationFrame(render);
      renderer.render(scene, camera);
  }

  function headInit(){

    makeHead();
    makeEye();
    makeEar();
    makeLines();
    hairInit();
    headG.rotation.x = PI/20;
    bodyG.add(headG);

  }


///////////////////////////////////////////////////////////////







function footInit(){
  //defs
  const node = pipeNode;
  const edge = pipeEdge;
  let toeThick = new Array(node);
  let toeWidth = new Array(node);
  let toe_ampt = footThick * 3;
  let toe_ampw = footThick * 1;
  let toeLength = footLength;


  //thick
  for(let i=0; i<node; i++){
      let t = i/(node-1);
      upperFootThick[i] = footThick;
      lowerFootThick[i] = footThick * Math.cos(Math.pow(t,2.5)*PI/3.8);
      lowerFootWidth[i] = lowerFootThick[i];
      //toe
      let theta1 = 1.6 * Math.pow(t,0.8) * PI/2;
      let theta2 = 1.4 * Math.pow(t,2) * PI/2;
      toeThick[i] = toe_ampt * Math.sin(theta1) + ankleThick;
      toeWidth[i] = toe_ampw * Math.sin(theta2) + ankleThick;

  }

  //meke upper foot
  let ep = new THREE.Vector2( footLength,0 );
  let ufoot_pt = makePipe(OPEN, node, edge, ep, ep, upperFootThick, upperFootThick);
  let ufoot_geo = makeGeometry(node, edge, ufoot_pt);
  ufoot_geo = mergeGeometry(ufoot_geo);
  upperFootGeoL = ufoot_geo.clone();
  upperFootGeoR = ufoot_geo.clone();
  lowerFootGeoL = ufoot_geo.clone();
  lowerFootGeoR = ufoot_geo.clone();
  let ufoot_objL = new THREE.Mesh(upperFootGeoL, bodyMat);
  let ufoot_objR = new THREE.Mesh(upperFootGeoR, bodyMat);
  let lfoot_objL = new THREE.Mesh(lowerFootGeoL, skinMat);
  let lfoot_objR = new THREE.Mesh(lowerFootGeoR, skinMat);

  //joint
  let jfoot_pt = makeJoint(node, edge, footThick, -PI/100);
  jointFootGeoL = makeGeometry(node, edge, jfoot_pt);
  jointFootGeoL = mergeGeometry(jointFootGeoL);
  jointFootGeoR = jointFootGeoL.clone();
  ankleGeoL = jointFootGeoL.clone();
  ankleGeoR = jointFootGeoL.clone();
  let jfoot_objL = new THREE.Mesh(jointFootGeoL, bodyMat);
  let jfoot_objR = new THREE.Mesh(jointFootGeoR, bodyMat);
  let ankle_objL = new THREE.Mesh(ankleGeoL, bodyMat);  
  let ankle_objR = new THREE.Mesh(ankleGeoR, bodyMat);

  //toe
  let toe_ep = new THREE.Vector2( toeLength,0 );
  let toe_pt = makePipe(CLOSE, node, edge, toe_ep, toe_ep, toeThick, toeThick);
  let toe_geo = makeGeometry(node+1, edge, toe_pt);
  toe_geo = mergeGeometry(toe_geo);
  let toe_objL = new THREE.Mesh(toe_geo, skinMat);

  scene.add(toe_objL);
  toe_objL.position.x = 100;


  //Grouping-L
  lowerFootGL.add(lfoot_objL);
  //lowerFootGL.add(toe_objL);
  kneeGL.add(jfoot_objL);
  kneeGL.add(lowerFootGL);
  footGL.add(ufoot_objL);
  footGL.add(kneeGL);

  //Grouping-R
  lowerFootGR.add(lfoot_objR);
  //lowerFootGL.add(toe_objR);
  kneeGR.add(jfoot_objR);
  kneeGR.add(lowerFootGR);
  footGR.add(ufoot_objR);
  footGR.add(kneeGR);

  footGR.position.x = -100;
  footG.add(footGL);
  footG.add(footGR);

  //bodyG.add(armG);

  scene.add(footG);
  //footGR.position.y = -60;
}




function footUpdate( side, v1, v2, rot1, rot2 ){
  //clear
  lowerPipePos.set(0,0);
  pipeRad = 0;

  //defs
  let node = pipeNode;
  let edge = pipeEdge;

  //value mapping
  const bend1 = mapping(v1, -1.0, 2.0, PI/4, -PI/2);
  const bend2 = mapping(v2, 0.001, 1.5, 0.0, -3*PI/4);
  let {ep1, cp1, ep2, cp2} = getBezierPt(footLength, footLength2, bend1, bend2);

  let upper_geo = side ? upperFootGeoR : upperFootGeoL;
  let joint_geo = side ? jointFootGeoR : jointFootGeoL;
  let lower_geo = side ? lowerFootGeoR : lowerFootGeoL;
  //let hand = side ? handGR : handGL;
  let joint = side ? kneeGR : kneeGL;
  let lower_foot = side ? lowerFootGR : lowerFootGL;
  let foot = side ? footGR : footGL;
  let pos = side ? -100 : 100;

  //geoUpdate
  let upper_pt = makePipe(OPEN, node, edge, ep1, cp1, upperFootThick, upperFootThick);
  updateGeometry(node, edge, upper_pt, upper_geo);

  let joint_pt = makeJoint(node, edge, footThick, bend2);
  updateGeometry(node, edge, joint_pt, joint_geo);
  joint.position.set(ep1.x, ep1.y, 0);

  let lower_pt = makePipe(OPEN, node, edge, ep2, cp2, lowerFootThick, lowerFootWidth);
  updateGeometry(node, edge, lower_pt, lower_geo);
  lower_foot.position.set(lowerPipePos.x,lowerPipePos.y,0);



  //hand
  //hand.position.set(ep2.x, ep2.y, 0);
  //hand.rotation.z = pipeRad;

  //rotation
  let axis1 = new THREE.Vector3(1,0,0);
  let diff = Math.abs(bend1) * -Math.PI/8;
  let bend = bend1 + diff;
  let axis2 = new THREE.Vector3(Math.cos(bend),Math.sin(bend),0);
  axis2.normalize();
  let q1 = new THREE.Quaternion();
  let q2 = new THREE.Quaternion();
  q1.setFromAxisAngle(axis1,rot1-PI/2);
  q2.setFromAxisAngle(axis2,rot2+PI);
  joint.applyQuaternion(q2);
  foot.applyQuaternion(q1);

  foot.position.y = -50;
  foot.position.x = pos;
  foot.rotation.y = PI/2;
}

function makeToe(){




}


function makeGlass(){
  //defs
  let size = headSize/6;
  let thick = size/5.5;
  let node = reso;
  let edge = headEdge;
  let radius = new Array(node);

  //material
  const material = new THREE.MeshPhongMaterial({
   //side:THREE.DoubleSide,
   color: 0x050503,
   opacity: 0.95,
   shininess: 35,
   specular : new THREE.Color(0x090703),
   transparent: true,
 });

  //thick
  for(let i=0; i<node; i++){
    let t = i / (node-1);
    radius[i] = size * Math.cos(t*PI/2.1);
  }
  //geometry
  let ep = new THREE.Vector2( thick,0 );
  let pt = makePipe(CLOSE, node, edge, ep, ep, radius, radius);
  let geo = makeGeometry(node+1, edge, pt);
  geo = mergeGeometry(geo);
  let glassL = new THREE.Mesh( geo, material );
  glassL.rotation.y = -PI/2;
  glassL.rotation.z = PI/18;
  let glassR = glassL.clone();
  //position
  let pos = headPtCal(0.48,-0.15);
  let z = pos[2]*1.13;
  glassL.position.set(pos[0], pos[1], z);
  glassR.position.set(-pos[0], pos[1], z);

  //bridge
  let len = size / 1.7;
  let thick2 = thick / 2;
  let geo2 = new THREE.CylinderGeometry( thick2, thick2, len, edge );
  const material2 = new THREE.MeshLambertMaterial({color: 0x393939});
  let bridge = new THREE.Mesh( geo2, material2 );
  bridge.rotation.z = PI/2;
  bridge.position.set(0,pos[1],z);

  //temple
  let len2 = size * 2.3;
  let thick3 = thick / 3;
  let geo3 = new THREE.CylinderGeometry( thick3, thick3, len2, edge );
  let templeL = new THREE.Mesh( geo3, material2 );

  let pos2 = headPtCal(0.46,0.4);
  templeL.position.x = pos2[0];
  templeL.position.y = pos2[1];
  templeL.position.z = 15;
  templeL.rotation.x = PI/2;
  templeL.rotation.y = PI/6;
  templeL.rotation.z = PI/11;
  let templeR = templeL.clone();
  templeR.position.x = -pos2[0];
  templeR.rotation.x = -PI/2;
  //templeR.rotation.y = -PI/6;
  //templeR.rotation.z = -PI/9;

  //side
  let side_pt = [];
  let z_w = 10; //奥行き
  let x_w = 9; //幅
  for(let i=0; i<node; i++){
    side_pt[i] = [];
    let t = i / (node-1);
    let phase = Math.pow(t, 1.5) * PI/2.3;
    let f = 1 - ( phase/(PI/2) );
    let z = t * z_w;
    let div = t * x_w;
    for(let j=0; j<edge; j++){
      let theta = j * PI / edge;
      let y = -size * Math.cos( f*theta+phase );
      let x = size * Math.sin( f*theta+phase )+div;
      side_pt[i][j] = [x, y, -z];
    }
  }
  //ruco
  let side_geo = makeGeometry(node, edge, side_pt);
  side_geo = mergeGeometry(side_geo);
  let side_obj = new THREE.Mesh( side_geo, material2 );

  side_obj.position.x = size;
  side_obj.rotation.x = -PI/18;
  side_obj.position.z = 45;
  side_obj.position.y = 10;
let side_objR = new THREE.Mesh( side_geo, material2 );

side_objR.rotation.z = PI;
side_objR.position.z = 45;
  side_objR.position.y = 10;
side_objR.position.x = -size;
  side_objR.rotation.x = -PI/18;



  //console.log(size);
  //side_obj.rotation.y = PI/2;


  //grouping
  let glassG = new THREE.Group();
  glassG.add(templeL);
  glassG.add(templeR);
  glassG.add(side_obj);
  glassG.add(side_objR);
  glassG.add(glassL);
  glassG.add(glassR);
  glassG.add(bridge);
  headG.add(glassG);



  //let geoo = new THREE.CylinderGeometry( 20, 20, 30, 12 );


}




///////body



function bodyInit(){
  //defs
  const node = bodyNode;
  const edge = bodyEdge;
  const h = bodyLength;

  //thick
  for(let i=0;i<node;i++){
    let t = i/(node-1);
    bodyWidths[i] = bodyWidth * Math.cos(Math.pow(t,1.8)*PI/5);
    bodyThicks[i] = bodyWidths[i] * 0.65;
  }

  pipeRad = PI/2;
  const ep = new THREE.Vector2( 0, h );
  let pt = makePipe(OPEN, node, edge, ep, ep, bodyWidths, bodyThicks);
  bodyGeo = makeGeometry(node, edge, pt);

  //uvmap
  let uvmap = [];
  for(let i=0; i<node; i++){
    uvmap[i] = [];
    let y = i/(node-1);
    for(let j=0; j<edge+1; j++){
      let x = j/edge;
      uvmap[i][j] = [x, y];
    }
  }
  let uvs = setUvs(node, edge, uvmap);
  bodyGeo.addAttribute('uv', new THREE.BufferAttribute(uvs, 2) );
  bodyGeo = mergeGeometry(bodyGeo);

  //material
  const texture = loader.load('img/torso.png');
  let mat = material.clone();
  mat.vertexShader = uv_vert;
  mat.fragmentShader = uv_frag;
  mat.uniforms.uTexture.value = texture;
  let obj = new THREE.Mesh(bodyGeo, mat);

  makeHip();

  bodyG.add(obj);
  scene.add(bodyG);
}


function makeHip(){

  const node = Math.floor(bodyNode/2);
  const edge = bodyEdge;
  const h = bodyLength/3.2;
  const center = new THREE.Vector2();

  let pt = [];
  for(let i=0; i<node; i++){
    pt[i] = [];
    let t = i / (node-1);
    let width = bodyWidth * Math.cos(t * PI/2.8);
    let thick = width * 0.65;
    let z = t * h;
    for(let j=0; j<edge; j++){
      let theta = j * 2 * PI/edge;
      let r = Math.pow(Math.cos(theta)/width,2) + Math.pow(Math.sin(theta)/thick,2);
      r = Math.sqrt(1/r);
      let v = new THREE.Vector2(1,0);
      v.rotateAround(center, -theta);
      let p = v.multiplyScalar(r);
      pt[i][j] = [p.x, p.y, z];
    }
  }
  let geo = makeGeometry(node, edge, pt);
  geo = mergeGeometry(geo);
  const mat = new THREE.MeshLambertMaterial({
    color: 0xff0000,
    //wireframe: true
  });
  let obj = new THREE.Mesh( geo, mat );
  bodyG.add(obj);
  obj.rotation.x = PI/2;

}



function bodyUpdate( lr_value, fb_value, tw_value ){
  //defs
  const node = bodyNode;
  const edge = bodyEdge;
  const seg = edge/4;
  const h = bodyLength;

  //arm_pos
  const arm_node = Math.floor(node*0.85);
  let arm_posL;
  let arm_posR;

  //value mapping
  const lr = mapping(lr_value, -1, 1, 3*PI/4, PI/4);
  const fb = mapping(fb_value, -1, 1.5, 3*PI/4, PI/8);
  const tw = mapping(tw_value, -1, 1, PI/4, -PI/4);

  //calc bone
  const x = h * Math.cos(lr);
  const y = h * Math.sin(lr) * Math.sin(fb);
  const z = h * Math.sin(lr) * Math.cos(fb);
  const ep = new THREE.Vector3(x, y, z);
  const cp = new THREE.Vector3(0, h/2, 0);
  const center = new THREE.Vector3();
  let curve = new THREE.QuadraticBezierCurve3(center,cp,ep);
  let bone = curve.getPoints( node-1 );
  bone[0] = new THREE.Vector3(0,1,0);

  //set points
  let pt = [];
  for(let i=0;i<node;i++){
      pt[i] = [];
      //make base
      let t = i/(node-1);
      let rot = Math.pow(t,0.7) * tw;
      let base = new THREE.Vector3(Math.cos(rot), 0, Math.sin(rot));
      let front = base.cross(bone[i]).normalize();
      let left = front.clone().cross(bone[i]).normalize();
      let back = front.clone().negate();
      let right = left.clone().negate();
      //body width
      let width = bodyWidths[i];
      let thick = bodyThicks[i];
      let y = i==0 ? new THREE.Vector3() : bone[i];
      //arm pos
      if(i==arm_node){
        arm_posL = right.clone().multiplyScalar(width*0.8).add(y);
        arm_posR = left.clone().multiplyScalar(width*0.8).add(y);
      }
      for(let j=0; j<seg; j++){
        //defs
        let div = j / seg;
        let d1 = div * PI/2;
        let d2 = PI/2 - d1;
        //radius
        let r1 = Math.pow(Math.cos(d1)/width,2) + Math.pow(Math.sin(d1)/thick,2);
        r1 = Math.sqrt(1/r1);
        let r2 = Math.pow(Math.cos(d2)/width,2) + Math.pow(Math.sin(d2)/thick,2);
        r2 = Math.sqrt(1/r2);
        //units
        let front_left = front.clone().lerp(left,div).normalize();
        let left_back = left.clone().lerp(back,div).normalize();
        let back_right = front_left.clone().negate();
        let right_front = left_back.clone().negate();
        //set points
        pt[i][j+0*seg] = front_left.multiplyScalar(r2).add(y).toArray();
        pt[i][j+1*seg] = left_back.multiplyScalar(r1).add(y).toArray();
        pt[i][j+2*seg] = back_right.multiplyScalar(r2).add(y).toArray();
        pt[i][j+3*seg] = right_front.multiplyScalar(r1).add(y).toArray();
      }
  }
  updateGeometry(node, edge, pt, bodyGeo);

  //head_pos
  const head_len = h + headSize/2.1;
  let head_pos = ep.clone().normalize().multiplyScalar(head_len);
  headG.position.set(head_pos.x, head_pos.y, head_pos.z);
  headG.rotation.z = lr - PI/2;
  headG.rotation.x = PI/2 - fb;
  headG.rotation.y = -tw;

  //arm_pos
  armGL.position.set(arm_posL.x, arm_posL.y, arm_posL.z);
  armGR.position.set(arm_posR.x, arm_posR.y, arm_posR.z);
  armGL.rotation.z = lr - PI/2;
  armGR.rotation.z = PI/2 - lr;
  armG.rotation.x = fb - PI/2;
  armGL.rotation.y = -tw;
  armGR.rotation.y = PI - tw;
}




//////////////////////////head

  function makeHead(){
    //defs
    const node = headNode;
    const edge = headEdge;

    //material
    const texture = loader.load('img/head.png');
    const tone = loader.load('img/skin_tone.png');
    let mat = material.clone();
    mat.vertexShader = uv_vert;
    mat.fragmentShader = tri_frag;
    mat.uniforms.uColor1.value = skinCol;
    mat.uniforms.uColor2.value = hairCol;
    mat.uniforms.uTexture.value = texture;
    mat.uniforms.uTone.value = tone;

    //uvmap
    let uvmap = [];
    for(let i=0; i<node; i++){
      uvmap[i] = [];
      let y = 1-(i*1.0/node);
      for(let j=0; j<edge+1; j++){
        let x = 1.0 - (j*1.0/edge);
        uvmap[i][j] = [x, y];
      }
    }
    let uvs = setUvs(node, edge, uvmap);

    //geometry
    let pt = [];
    const m = edge/2.0;
    for(let i=0; i<node; i++){
      let ndiv = i*1.0/(node-1);
      pt[i] = [];
      for(let j=0; j<edge; j++){
        let ediv = ( (2*m-j) - 2*(m-(j%m) ) ) / m;
        pt[i][j] = headPtCal(ndiv, ediv);
      }
      pt[i][edge] = headPtCal(ndiv, 0);
    }
    let geo = makeGeometry(node, edge, pt);
    geo.addAttribute('uv', new THREE.BufferAttribute(uvs, 2) );
    let geo_merg = mergeGeometry(geo);

    //scene_add
    let obj = new THREE.Mesh(geo_merg, mat);
    headG.add(obj);
  }


  function makeEye(){
    //vars
    const node = reso;
    const edge = 3 * reso;
    const size = headSize/5.8;
    const base = size/3.2;

    //geometry
    let pt = [];
    let z = 0;
    for(let i=0;i<node;i++){
      pt[i] = [];
      let r = (node-1-i) * size / node;
      let thick = Math.pow((node-i)*1.0/node, 4) * base;
      z += thick;
      for(let j=0;j<edge+1;j++){
        let x = r * Math.cos( j*2*PI/(edge) );
        let y = r * Math.sin( j*2*-PI/(edge) );
        if(i==0){z = thick - Math.abs( r/8 * Math.cos( j*2*PI/(edge) ) );}
        pt[i][j] = [x,y,z];
      }
    }
    let geo = makeGeometry(node, edge, pt);

    //uv
    let uvmap = [];
    for(let i=0;i<node;i++){
      uvmap[i] = [];
      for(let j=0;j<edge+1;j++){
        let x = mapping(pt[i][j][0],-size, size, 0.0, (node-1)/node);
        let y = mapping(pt[i][j][1],-size, size, 0.0, (node-1)/node);
        uvmap[i][j] = [x,y];
      }
    }
    let uvs = setUvs(node, edge, uvmap);

    geo.addAttribute('uv', new THREE.BufferAttribute(uvs, 2) );
    let geo_merg = mergeGeometry(geo);

    //materials
    eyeMat.vertexShader = uv_vert;
    eyeMat.fragmentShader = bi_frag;
    eyeMat.uniforms.uColor1.value = highCol;
    eyeMat.uniforms.uColor2.value = eyeCol;
    eyeMat.uniforms.uTexture.value = eyeTex1;

    //position
    const posL = headPtCal(0.5, 0.16);
    const posR = headPtCal(0.5, -0.16);
    const pos = [posL, posR];
    const roty = [PI/12, -PI/12];
    for(let i=0; i<2; i++){
      let sPos = new THREE.Vector3(pos[i][0], pos[i][1], pos[i][2]);
      sPos.z *= 0.91;
      let obj = new THREE.Mesh(geo_merg, eyeMat);
      obj.position.set(sPos.x, sPos.y, sPos.z);
      obj.rotation.x = -PI/12;
      obj.rotation.y = roty[i];
      headG.add(obj);
    }
  }

  function makeEar(){
    //defs
    const edge = 8;
    const node = 6;
    const s = headSize/10;

    //thick
    let w1 = new Array(node);
    let w2 = new Array(node);
    for(let i=0; i<node; i++){
      let t = i * 1.0/(node-1);
      w1[i] = s * Math.cos(t*PI/2);
      w2[i] = w1[i]/3;
    }

    const ep = new THREE.Vector2( s,0 );
    const cp = new THREE.Vector2( s,0 );
    let pt = makePipe(OPEN, node, edge, ep, cp, w1, w2);
    let geo = makeGeometry(node, edge, pt);
    let geo_merg = mergeGeometry(geo);

    //position
    const posL = headPtCal(0.52, 0.5);
    const posR = headPtCal(0.52, -0.5);
    const pos = [posL, posR];
    const roty = [0, PI];
    for(let i=0; i<2; i++){
      let sPos = new THREE.Vector3(pos[i][0], pos[i][1], pos[i][2]);
      let obj = new THREE.Mesh(geo_merg, skinMat);
      sPos.x *= 0.97;
      obj.position.set(sPos.x, sPos.y, sPos.z);
      obj.rotation.y = roty[i];
      obj.rotation.x = -PI/14;
      headG.add(obj);
    }
  }





  function makeHair(p){
    //defs
    const len = p.len * headSize/3;
    const node = reso * 2;
    const edge = reso * 2;
    const w = p.w * headSize/10;
    const t = w * 0.4 * p.t;
    const endw = PI/2 * p.endw;
    const endt = PI/2 * p.endt;

    //thick
    let width = new Array(node);
    let thick = new Array(node);
    for(let i=0; i<node; i++){
      let c = i / (node-1);
      width[i] = w * Math.cos(Math.pow(c,p.cw)*(endw));
      thick[i] = t * Math.cos(Math.pow(c,p.ct)*(endt));
    }

    //cal step
    const center = new THREE.Vector2();
    let ep = new THREE.Vector2( len*p.ep.x, len*p.ep.y);
    let cp1 = new THREE.Vector2( len*p.cp1.x, len*p.cp1.y);
    let cp2 = new THREE.Vector2( len*p.cp2.x, len*p.cp2.y);
    let curve = new THREE.CubicBezierCurve(center, cp1, cp2, ep);
    let bone = curve.getPoints( node-1 );

    //set points
    let zpos = new THREE.Vector2();
    let rot = 0;
    let pt = [];
    for(var i=0; i<node; i++){
      pt[i] = [];
      let diff = new THREE.Vector2();
      diff.subVectors(bone[i], zpos);
      rot = Math.atan2(diff.y, diff.x);
      for(var j=0; j<edge; j++){
        let theta = j * 2 * PI / edge;
        let w = width[i] * Math.cos( theta );
        let h = thick[i] * Math.sin( theta )
        let v = new THREE.Vector2(0, h);
        v.add(bone[i]);
        v.rotateAround(bone[i], rot);
        pt[i][j] = [v.x, v.y, w];
      }
      zpos = bone[i];
    }

    let geo = makeGeometry(node, edge, pt);
    let geo_merg = mergeGeometry(geo);

    let obj = new THREE.Mesh(geo_merg, hairMat);
    let pos = headPtCal(p.y, p.x);
    obj.position.set(pos[0], pos[1]*0.85, pos[2]*0.9);
    obj.rotation.x = p.rotx;
    obj.rotation.y = -PI/2 + p.roty;
    headG.add(obj);
  }



  function hairInit(){
    //1
    let params = {
      len: 0.9, //length
      w: 1.11, //base_width
      t: 1, //base_thick
      endw: 0.96, //end_radius w
      endt: 0.95, //end_radius t
      cw: 0.7, //curve intense w
      ct: 1.3, //curve intense t
      x: -0.48, //posx -1 - 1
      y: 0.06, //posy -1 - 1
      rotx: PI/18, //rotatex
      roty: -PI/5, //rotatey
      ep: new THREE.Vector2( 1, 0.2 ),
      cp1: new THREE.Vector2( 0.5, -1/8 ),
      cp2: new THREE.Vector2( 1.2, -0.2 ),
    };
    //makeHair(params);

    //2
    let params2 = {
      len: 0.7, //length
      w: 1.5, //base_width
      t: 1.3, //base_thick
      endw: 0.96, //end_radius w
      endt: 0.95, //end_radius t
      cw: 0.7, //curve intense w
      ct: 1.3, //curve intense t
      x: -0.1, //posx -1 - 1
      y: 0.03, //posy -1 - 1
      rotx: 0, //rotatex
      roty: -PI/12, //rotatey -migi
      ep: new THREE.Vector2( 1.1, 0.45 ),
      cp1: new THREE.Vector2( 0.3, 0 ),
      cp2: new THREE.Vector2( 1, 0 ),
    };
    makeHair(params2);

    params2.w = 0.8;
    params2.x = -0.4;
    params2.y = 0.06;
    params2.ep.x = 0.9;
    params2.ep.y = 0.3;
    params2.cp2.x = 0.8;
    //params2.cp2.y = 1.2;
    params2.cp1.x = 0.6;
    params2.roty = -PI/32;
    params2.rotx = -PI/24;
    makeHair(params2);

    params2.x = 0.1;
    params2.y = 0.04;
    makeHair(params2);



    //headG.rotation.y = PI/4.5;




  }





  function makeLines(){
    const line_width = headSize/30;
    const mat = new THREE.LineBasicMaterial({
      color: 0x000000, linewidth: line_width});

    const mo_w = 0.02;
    const mo_h = mo_w * 0.9;
    const moEdge = Math.round(headSize/5);
    let moGeoL = new THREE.Geometry();
    let moGeoR = new THREE.Geometry();
    for(let i=0;i<moEdge;i++){
      let x = mo_w * Math.cos(i * PI/(moEdge-1)) + mo_w;
      let y = mo_h * Math.sin(i * PI/(moEdge-1)) + 0.69;
      let moPt = headPtCal(y,x);
      moGeoL.vertices.push(new THREE.Vector3( moPt[0], moPt[1], moPt[2]) );
      moGeoR.vertices.push(new THREE.Vector3( -moPt[0], moPt[1], moPt[2]) );
    }
    const moObjL = new THREE.Line( moGeoL, mat );
    const moObjR = new THREE.Line( moGeoR, mat );
    headG.add( moObjL );
    headG.add( moObjR );


    /////eye_lash
    const posL = headPtCal(0.36, 0.12);
    const posR = headPtCal(0.37, -0.22);
    const len = headSize/22;
    const center = new THREE.Vector3();
    const ep = new THREE.Vector3(-len, len, 0);
    let lash_geoL = new THREE.Geometry();
    lash_geoL.vertices.push(center);
    lash_geoL.vertices.push(ep);
    let lash_objL = new THREE.Line( lash_geoL, mat );
    let lash_objR = lash_objL.clone();
    lash_objL.position.set(posL[0], posL[1], posL[2]);
    lash_objR.position.set(posR[0], posR[1], posR[2]);
    //group
    let lashes = new THREE.Group();
    lashes.add(lash_objL);
    lashes.add(lash_objR);
    eyelashObj = lashes;
    headG.add(lashes);


    ////eye_brown
    let ebPt1L = headPtCal(0.22, -0.14);
    let ebPt2L = headPtCal(0.235, -0.20);
    let ebPt1R = headPtCal(0.22, 0.14);
    let ebPt2R = headPtCal(0.235, 0.20);

    let ebGeoL = new THREE.Geometry();
    let ebGeoR = new THREE.Geometry();

    ebGeoL.vertices.push(new THREE.Vector3( ebPt1L[0], ebPt1L[1], ebPt1L[2]) );
    ebGeoL.vertices.push(new THREE.Vector3( ebPt2L[0], ebPt2L[1], ebPt2L[2]) );
    ebGeoR.vertices.push(new THREE.Vector3( ebPt1R[0], ebPt1R[1], ebPt1R[2]) );
    ebGeoR.vertices.push(new THREE.Vector3( ebPt2R[0], ebPt2R[1], ebPt2R[2]) );

    let ebObjL = new THREE.Line( ebGeoL, mat );
    let ebObjR = new THREE.Line( ebGeoR, mat );
    headG.add( ebObjL );
    headG.add( ebObjR );
  }


  function headPtCal(ndiv, ediv){
    //variables
    if(ndiv==0||ndiv==1){ediv=0;}
    const pidiv = Math.abs(ediv);
    const amp1 = 0.13;
    const amp2 = 0.1;
    const ffreq = 3.0;
    const bfreq1 = 0.4;
    const bfreq2 = 0.9;
    const fphase1 = 1.4;
    const fphase2 = -0.35;
    const bphase1 = 2.0;
    const bphase2 = -1.8;
    const c = 0.41;
    //cal step
    const cp = 0.4;
    const x1 = 3 * cp * ndiv * Math.pow((1-ndiv), 2);
    const x2 = 3 * cp * Math.pow(ndiv, 2) * (1-ndiv);
    const x3 = Math.pow(ndiv, 3);
    const step = x1 + x2 + x3;
    //params
    const amp = (1-ndiv)*amp1 + ndiv*amp2;
    const bfreq = (1-ndiv)*bfreq1 + ndiv*bfreq2;
    const fphase = (1-step)*fphase1 + step*fphase2;
    const bphase = (1-step)*bphase1 + step*bphase2;
    //synthesis
    const front = amp * Math.sin(step*ffreq*PI+fphase) + c;
    const back = amp * Math.sin(step*bfreq*PI+bphase) + c;
    const p_temp = Math.pow(pidiv,1.3);
    let p = p_temp>0.45 ? Math.pow(1.0-p_temp, 3) + p_temp : p_temp;
    let scale = p_temp>0.45
      ? 0.15 * Math.sin(1.8*(pidiv-0.5)*PI+PI/8)+1.12
      : 0.14 * Math.sin(1.8*pidiv*PI)+1.245;
    const synth = (1-p)*front + p*back;
    //set points
    const thita = step * PI;
    const phi = ediv * PI;
    const z = headSize * synth * Math.sin(thita) * Math.cos(phi) * scale;
    const x = headSize * synth * Math.sin(thita) * Math.sin(phi) * scale;
    const y = headSize * synth * Math.cos(thita);
    let pt = [x,y,z];
    return pt;
  }




//////////////////////arm




  function armInit(){
    //defs
    const node = pipeNode;
    const edge = pipeEdge;
    const hand_thick = armThick * Math.cos(PI/3.5);
    const hand_width = armThick * Math.cos(PI/4.8);
    const fing_thick = armThick / 4.5;
    let handThick = new Array(pipeNode);
    let handWidth= new Array(pipeNode);
    let fingThick = new Array(pipeNode);
    const numFing = 4;

    //thick
    for(let i=0; i<node; i++){
        let t = i * 1.0/(node-1);
        upperArmThick[i] = armThick;
        lowerArmThick[i] = armThick * Math.cos(Math.pow(t,2.5)*PI/3.8);
        lowerArmWidth[i] = armThick * Math.cos(Math.pow(t,2.5)*PI/5);
        handThick[i] = hand_thick * Math.cos(t*PI/3);
        handWidth[i] = hand_width * Math.cos(t*PI/5);
        fingThick[i] = fing_thick * Math.cos(t*PI/2.5);
    }

    //make hand obj
    const hand_len = armLength / 5;
    const hp = new THREE.Vector2( hand_len, 0 );
    let hand_pt = makePipe(CLOSE, node, edge, hp, hp, handThick, handWidth);
    let geoHand = makeGeometry(node+1, edge, hand_pt);
    geoHand = mergeGeometry(geoHand);
    let objHand = new THREE.Mesh(geoHand, skinMat);
    handGL.add(objHand);

    //make fingers obj
    const fp = hp.multiplyScalar(0.85);
    let fing_pt = makePipe(CLOSE, node, edge, fp, fp, fingThick, fingThick);
    let geoFing = makeGeometry(node+1, edge, fing_pt);
    geoFing = mergeGeometry(geoFing);
    let obj_fing = new THREE.Mesh(geoFing, skinMat);
    for(let i=0; i<numFing; i++){
      let obj = obj_fing.clone();
      let angle = [-PI/6, -PI/18, PI/16, PI/5];
      let z = hand_len/0.7 * Math.sin(angle[i]);
      let x = hand_len/1.1 * Math.cos(angle[i]);
      let pos = new THREE.Vector3(x, 0, z);
      obj.rotation.y = -angle[i];
      obj.position.set(pos.x, pos.y, pos.z);
      handGL.add(obj);
    }
    handGR = handGL.clone();

    //meke upper arm
    let ep = new THREE.Vector2( armLength,0 );
    let cp = new THREE.Vector2();
    let armu_pt = makePipe(OPEN, node, edge, ep, cp, upperArmThick, upperArmThick);
    upperArmGeoL = makeGeometry(node, edge, armu_pt);
    upperArmGeoL = mergeGeometry(upperArmGeoL);
    upperArmGeoR = upperArmGeoL.clone();
    let uarm_obj = new THREE.Mesh(upperArmGeoL, bodyMat);
    let uarm_objR = new THREE.Mesh(upperArmGeoR, bodyMat);

    //joint
    let armj_pt = makeJoint(node, edge, armThick, -PI/100);
    jointArmGeoL = makeGeometry(node, edge, armj_pt);
    jointArmGeoL = mergeGeometry(jointArmGeoL);
    jointArmGeoR = jointArmGeoL.clone();
    let jarm_obj = new THREE.Mesh(jointArmGeoL, bodyMat);
    let jarm_objR = new THREE.Mesh(jointArmGeoR, bodyMat);

    //lower_arm
    let ep2 = new THREE.Vector2( armLength2,0 );
    let cp2 = new THREE.Vector2();
    let arml_pt = makePipe(OPEN, node, edge, ep2, cp2, lowerArmThick, lowerArmWidth);
    lowerArmGeoL = makeGeometry(node, edge, arml_pt);
    lowerArmGeoL = mergeGeometry(lowerArmGeoL);
    lowerArmGeoR = lowerArmGeoL.clone();
    let larm_obj = new THREE.Mesh(lowerArmGeoL, bodyMat);
    let larm_objR = new THREE.Mesh(lowerArmGeoR, bodyMat);

    //Grouping-L
    armGL.add(uarm_obj);
    lowerArmGL.add(larm_obj);
    lowerArmGL.add(handGL);
    elbowGL.add(jarm_obj);
    elbowGL.add(lowerArmGL);
    armGL.add(elbowGL);

    //Grouping-R
    armGR.add(uarm_objR);
    lowerArmGR.add(larm_objR);
    lowerArmGR.add(handGR);
    elbowGR.add(lowerArmGR);
    elbowGR.add(jarm_objR);
    armGR.add(elbowGR);

    armG.add(armGR);
    armG.add(armGL);
    bodyG.add(armG);
  }





  function armUpdate( side, v1, v2, rot1, rot2){

    //clear
    lowerPipePos.set(0,0);
    pipeRad = 0;

    //defs
    let node = pipeNode;
    let edge = pipeEdge;

    //value mapping
    const bend1 = mapping(v1, -1.0, 2.0, PI/4, -PI/2);
    const bend2 = mapping(v2, 0.001, 1.5, 0.0, -3*PI/4);
    let {ep1, cp1, ep2, cp2} = getBezierPt(armLength, armLength2, bend1, bend2);

    let upper_geo = side ? upperArmGeoR : upperArmGeoL;
    let joint_geo = side ? jointArmGeoR : jointArmGeoL;
    let lower_geo = side ? lowerArmGeoR : lowerArmGeoL;
    let hand = side ? handGR : handGL;
    let joint = side ? elbowGR : elbowGL;
    let lower_arm = side ? lowerArmGR : lowerArmGL;
    let arm = side ? armGR : armGL;
    let rot = side ? PI : 0;

    //arm_geoUpdate
    let uarm_pt = makePipe(OPEN, node, edge, ep1, cp1, upperArmThick, upperArmThick);
    updateGeometry(node, edge, uarm_pt, upper_geo);

    let jarm_pt = makeJoint(node, edge, armThick, bend2);
    updateGeometry(node, edge, jarm_pt, joint_geo);
    joint.position.set(ep1.x, ep1.y, 0);

    let larm_pt = makePipe(OPEN, node, edge, ep2, cp2, lowerArmThick, lowerArmWidth);
    updateGeometry(node, edge, larm_pt, lower_geo);
    lower_arm.position.set(lowerPipePos.x,lowerPipePos.y,0);

    //hand
    hand.position.set(ep2.x, ep2.y, 0);
    hand.rotation.z = pipeRad;

    //rotation
    let axis1 = new THREE.Vector3(1,0,0);
    let diff = Math.abs(bend1) * -Math.PI/8;
    let bend = bend1 + bend2 + diff;
    let axis2 = new THREE.Vector3(Math.cos(bend),Math.sin(bend),0);
    axis2.normalize();
    let angle2 = rot2;
    let q1 = new THREE.Quaternion();
    let q2 = new THREE.Quaternion();
    q1.setFromAxisAngle(axis1,rot1);
    q2.setFromAxisAngle(axis2,rot2);
    lower_arm.applyQuaternion(q2);
    arm.applyQuaternion(q1);
    arm.rotation.y = rot;
  }



  function getBezierPt(len1, len2, bend1, bend2){
    //angle adjust
    let diff = Math.abs(bend1) * -Math.PI/8;
    let rad = bend1 + bend2 + diff;
    //arm1
    const x1 = len1 * Math.cos(bend1);
    const y1 = len1 * Math.sin(bend1);
    const ep1 = new THREE.Vector2( x1,y1 );
    let cp1 = new THREE.Vector2( 0,0 );
    ep1.y>0 ? cp1.y = y1/2 : cp1.x = -y1/2;
    //ep1.y>0 ? cp1.y = y1/2 : cp1.x = y1/2;
    //arm2
    const joint_len = armThick * Math.abs(bend2);
    len2 -= joint_len;
    const x2 = len2 * Math.cos(rad);
    const y2 = len2 * Math.sin(rad);
    const ep2 = new THREE.Vector2( x2,y2 );
    const cp2 = new THREE.Vector2( 0,0 );
    return {ep1, cp1, ep2, cp2}
  }


function blink(open){
  let tex = open ? eyeTex1 : eyeTex2;
  let col = open ? highCol : skinCol;
  eyeMat.uniforms.uTexture.value = tex;
  eyeMat.uniforms.uColor1.value = col;
  eyelashObj.visible = open;
}








////////////////////////共通関数


  function makePipe(open, node, edge, ep, cp, thick, width){
    //defs
    const center = new THREE.Vector2();
    let zpos = new THREE.Vector2();
    let pt = [];
    let rot = pipeRad;

    //bone
    let curve = new THREE.QuadraticBezierCurve(center,cp,ep);
    let bone = curve.getPoints( node-1 );

    //set points
    for(var i=0; i<node; i++){
      pt[i] = [];
      if(i!=0){
        let diff = new THREE.Vector2();
        diff.subVectors(bone[i], zpos);
        rot = Math.atan2(diff.y, diff.x);
      }
      for(var j=0; j<edge; j++){
        let theta = j*2*PI/edge;
        let w = width[i] * Math.cos(theta);
        let h = thick[i] * Math.sin(theta)
        let v = new THREE.Vector2(0, h);
        v.add(bone[i]);
        v.rotateAround(bone[i], rot);
        pt[i][j] = [v.x, v.y, w];
      }
      zpos = bone[i];
    }

    //closed face
    if(!open){
      pt[node] = [];
      for(var j=0; j<edge; j++){
        pt[node][j] = [bone[node-1].x, bone[node-1].y, 0];
      }
    }

    //update
    pipeRad = rot;
    return pt;
  }






  function makeJoint(node, edge, thick, rad){
    //defs
    let origin = new THREE.Vector2( 0,-thick );
    let init = new THREE.Vector2();
    origin.rotateAround(init, pipeRad);
    let center = new THREE.Vector2( 0,thick);
    center.add(origin);
    center.rotateAround(origin, pipeRad);

    //set pt
    let pt = [];
    for(let i=0; i<node; i++){
      pt[i] = [];
      let r = i==0 ? 0 : rad/(node-1);
      center.rotateAround(origin, r);
      for(let j=0; j<edge; j++){
        let theta = j*2*PI/edge;
        let w = thick * Math.cos(theta);
        let h = thick * Math.sin(theta);
        let v = new THREE.Vector2(0, h);
        v.add(center);
        v.rotateAround(center, i * r + pipeRad);
        pt[i][j] = [v.x, v.y, w];
      }
    }
    //update values
    pipeRad += rad;
    lowerPipePos.add(center);
    return pt;
}



  //mapping
  function mapping(value, inMin, inMax, outMin, outMax){
    let norm = (value - inMin)/(inMax - inMin);
    let out = norm * (outMax - outMin) + outMin;
    return out;
  }


  function updateGeometry(node, edge, pt, geometry){
    let vertices = setVertices(node, edge, pt);
    let geo_new = new THREE.BufferGeometry();
    geo_new.addAttribute('position', new THREE.BufferAttribute(vertices, NUM_POS));
    let geo_merg = new THREE.Geometry().fromBufferGeometry( geo_new );
    geo_merg.mergeVertices();
    geometry.vertices = geo_merg.vertices;
    geometry.verticesNeedUpdate = true;
    geometry.elementsNeedUpdate = true;
    geometry.computeVertexNormals();
  }

  function mergeGeometry(geo){
    let geo_merg = new THREE.Geometry().fromBufferGeometry( geo );
    geo_merg.mergeVertices();
    geo_merg.computeVertexNormals();
    return geo_merg;
  }

  function makeGeometry(node, edge, pt){
    const vertices = setVertices(node, edge, pt);
    const indices = setIndices(node, edge);
    let geometry = new THREE.BufferGeometry();
    geometry.addAttribute('position', new THREE.BufferAttribute(vertices, NUM_POS));
    geometry.setIndex(new THREE.BufferAttribute(indices, 1));
    return geometry;
  }



  function setUvs(node, edge, pt){
    const nPos = 2;
    const nVert = nPos * 4;
    const numVertices = nVert*(node-1)*edge;
    let vertices = new Float32Array(numVertices);
    for(let i=0; i<node-1; i++){
      for(let j=0; j<edge; j++){
        for(let k=0;k<nPos;k++){
          let n = i*nVert*edge + j*nVert + k;
          vertices[n+nPos*0] = pt[i][j][k];
          vertices[n+nPos*1] = pt[i][j+1][k];
          vertices[n+nPos*2] = pt[i+1][j+1][k];
          vertices[n+nPos*3] = pt[i+1][j][k];
        }
      }
    }
    return vertices;
  }


  function setVertices(node, edge, pt){
    let numVertices = VER_RECT*(node-1)*edge;
    let vertices = new Float32Array(numVertices);
    for(var i=0; i<node-1; i++){
      for(var j=0; j<edge; j++){
        for(var k=0;k<NUM_POS;k++){
          let n = i*VER_RECT*edge + j*VER_RECT + k;
          vertices[n+NUM_POS*0] = pt[i][j][k];
          vertices[n+NUM_POS*1] = pt[i][(j+1)%edge][k];
          vertices[n+NUM_POS*2] = pt[i+1][(j+1)%edge][k];
          vertices[n+NUM_POS*3] = pt[i+1][j][k];
        }
      }
    }
    return vertices;
  }


  function setIndices(node, edge){
    let numIndices = (VER_RECT*(node-1)*edge)/2;
    let order = [0,3,2,2,1,0];
    let indices = new Uint16Array(numIndices);
    for(let i=0; i<numIndices/6; i++){
      for(let j=0; j<order.length; j++){
        indices[i*6+j] = i*4+order[j];
      }
    }
    return indices;
  }

}

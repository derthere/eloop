//for the cirlce
int segs;
int steps = 8;
float rotAdjust = TWO_PI / segs / 4;
float radius;
float segWidth;

float interval = TWO_PI / segs;

XMLElement xml;
SensorData waterData;
SensorData VOCData;
SensorData tempData;
SensorData humidData;
SensorData soilData;

//make array for elements min, max, ave
ArrayList<DailyData> waterDailyValues;
ArrayList<DailyData> VOCDailyValues;
ArrayList<DailyData> tempDailyValues;
ArrayList<DailyData> humidDailyValues;
ArrayList<DailyData> soilDailyValues;

void setup() {
  size(600, 600);
  background(255);
  smooth();
  ellipseMode(RADIUS);
  noStroke();

  // data structure setup
  xml = new XMLElement(this, "data.xml");
  waterData = new SensorData("water", xml);
  VOCData = new SensorData("VOC", xml);
  tempData = new SensorData("temperature", xml);
  humidData = new SensorData("humidity", xml);
  soilData = new SensorData("soil", xml);

  //make array for elements min, max, ave
  waterDailyValues = waterData.getDailyData();
  VOCDailyValues = VOCData.getDailyData();
  tempDailyValues = tempData.getDailyData();
  humidDailyValues = humidData.getDailyData();
  soilDailyValues = soilData.getDailyData();


  // make the diameter 90% of the sketch area
  radius = min(width, height) * 0.45;
  segWidth = radius / steps;

  //look for elements

    //make arrays for each day

  segs = waterDailyValues.size(); // divide segments according to time span

  Val2Color(); //assign color values to each
  displayData(); //plot circle graph
}


void displayData() {

  for (int i = 0; i < segs; i++)
  {

    fill(tempcolor[i]); //filling each arc cone section
    arc(width/2, height/2, radius, radius, 
    interval*i+rotAdjust, interval*(i+.9)+rotAdjust);

    fill(255);     //white gap
    arc(width/2, height/2, radius *.75, radius* .75, 
    interval*i+rotAdjust, interval*(i+1)+rotAdjust);

    fill(aircolor[i]); //filling each arc cone section
    arc(width/2, height/2, radius* .74, radius* .74, 
    interval*i+rotAdjust, interval*(i+.9)+rotAdjust);

    fill(255);    //white gap
    arc(width/2, height/2, radius* .49, radius* .49, 
    interval*i+rotAdjust, interval*(i+1)+rotAdjust);     

    fill(watercolor[i]); //filling each arc cone section
    arc(width/2, height/2, radius* .48, radius* .48, 
    interval*i+rotAdjust, interval*(i+.9)+rotAdjust); 

    fill(#FFFFFF);  //white gap  
    arc(width/2, height/2, radius* .23, radius* .23, 
    interval*i+rotAdjust, interval*(i+1)+rotAdjust);     

    fill(soilcolor[i]);    
    arc(width/2, height/2, radius* .22, radius* .22, 
    interval*i+rotAdjust, interval*(i+.9)+rotAdjust);
  }

  radius -= segWidth *2 ;
}

public class DailyData {
  public float min, max, avg;
  public int numberOfValues;
  public String date;

  public DailyData(String _date, float _min, float _max, float _avg, int _nv) {
    date = _date;
    min = _min;
    max = _max;
    avg = _avg;
    numberOfValues = _nv;
  }
}

public class SensorData {
  private String sensorName;
  private ArrayList<Float> theValues;
  private ArrayList<String> theDateAndTime;

  private ArrayList<DailyData> theDailyData;

  private float theMin, theMax;

  public SensorData(String _name, XMLElement _xml) {
    theValues = new ArrayList<Float>();
    theDateAndTime = new ArrayList<String>();

    theDailyData = new ArrayList<DailyData>();

    theMin = MAX_FLOAT;
    theMax = -MAX_FLOAT;

    sensorName = _name;

    parseData(_name, _xml);
  }

  private void parseData(String _name, XMLElement _xml) {
    // Get all the data elements
    XMLElement[] children = _xml.getChildren("data");

    String lastDate = "";
    ArrayList<Float> tempDaily = new ArrayList<Float>();

    // parse data elements and get date and current_value for this tag/name/sensor
    for (int i = 0; i < children.length; i ++ ) {
      XMLElement nameElement = children[i].getChild("tag");
      String name = nameElement.getContent();

      if (name.equals(_name)) {
        XMLElement valueElement = children[i].getChild("current_value");
        float v = float(valueElement.getContent());
        String d = valueElement.getString("at");

        // add to raw array
        theValues.add(new Float(v));
        theDateAndTime.add(d);

        // min/max
        if (v<theMin) { 
          theMin = v;
        }
        if (v>theMax) { 
          theMax = v;
        }

        // ggrrrrrr!!!
        String date = (d.indexOf("T")>-1)?(d.substring(0, d.indexOf("T"))):("");
        // new day! calculate stuff!
        if (lastDate.equals(date) == false) {
          float tmin = MAX_FLOAT;
          float tmax = -MAX_FLOAT;
          float tsum = 0;

          for (int ii=0; ii<tempDaily.size(); ii++) {
            if (tempDaily.get(ii)<tmin) { 
              tmin = tempDaily.get(ii);
            }
            if (tempDaily.get(ii)>tmax) { 
              tmax = tempDaily.get(ii);
            }
            tsum += tempDaily.get(ii);
          }

          if ((tempDaily.size()>0) && (!lastDate.equals(""))) {
            theDailyData.add(new DailyData(lastDate, tmin, tmax, tsum/tempDaily.size(), tempDaily.size()));
          }
          tempDaily.clear();
        }
        // add to day array
        lastDate = date;
        tempDaily.add(new Float(v));
      }
    }

    // last day of data is still in the array when we get here
    if ((tempDaily.size()>0) && (!lastDate.equals(""))) {
      float tmin = MAX_FLOAT;
      float tmax = -MAX_FLOAT;
      float tsum = 0;

      for (int ii=0; ii<tempDaily.size(); ii++) {
        if (tempDaily.get(ii)<tmin) { 
          tmin = tempDaily.get(ii);
        }
        if (tempDaily.get(ii)>tmax) { 
          tmax = tempDaily.get(ii);
        }
        tsum += tempDaily.get(ii);
      }

      theDailyData.add(new DailyData(lastDate, tmin, tmax, tsum/tempDaily.size(), tempDaily.size()));
    }
    tempDaily.clear();
  }

  public void printInfo() {
    println("My name is "+sensorName);

    println("I got "+theValues.size()+" raw sensor values");
    println("My min is: "+theMin+", my max: "+theMax);

    println("---daily min,max,avg---");
    for (int i=0; i<theDailyData.size(); i++) {
      println("sensorName["+theDailyData.get(i).date+"]: "+
        theDailyData.get(i).min+" "+
        theDailyData.get(i).max+" "+
        theDailyData.get(i).avg);
    }
  }

  public ArrayList<DailyData> getDailyData() {
    return theDailyData;
  }
}


int[] tempcolor = new int[100];
int[] aircolor = new int[100];
int[] watercolor = new int[100];
int[] soilcolor = new int[100];

//air colors
String bad = "FFF50707"; //red
String ok = "FFF5DE07";//yellow
String good= "FF40ED35"; //green
String terrible = "FFCE34E0"; //pink

//temp colors
String verycold = "FF374BB7"; //darkblue
String hot = "FFE85625";// fire red
String cold = "FFC0E2EA"; // light blue
String warm = "FFF2D9D2"; //warm

//water colors
String clear = "FFE0FFFA"; //ice
String cloudy = "FFBABCBC"; //gray
String dirty = "FFA07C4F"; //mud

int badf = unhex(bad);
int okf = unhex(ok);
int goodf = unhex(good);
int terriblef = unhex(terrible);
int verycoldf = unhex(verycold);
int hotf = unhex(hot);
int coldf= unhex(cold);
int warmf = unhex(warm);
int clearf = unhex(clear);
int cloudyf = unhex(cloudy);
int dirtyf = unhex(dirty);

void Val2Color() {

  for (int i = 0; i<5; i++) {
    //temp hot to cold
    //println(voc.get(i));

    //temp based on max
    if (tempDailyValues.get(i).max < 20) {
      tempcolor[i] = verycoldf;
    }
    if (20 < tempDailyValues.get(i).max && tempDailyValues.get(i).max < 40) {
      tempcolor[i] = coldf;
    }
    if (tempDailyValues.get(i).max> 40 && tempDailyValues.get(i).max < 60) {
      tempcolor[i] = warmf;
    }
    if (tempDailyValues.get(i).max > 60) {
      tempcolor[i] = hotf;
    }

    //air good to bad based on ave
    if (VOCDailyValues.get(i).avg < 20) {
      aircolor[i] = badf;
    }
    if (20 < VOCDailyValues.get(i).avg  && VOCDailyValues.get(i).avg  < 40) {
      aircolor[i] = goodf;
    }
    if (VOCDailyValues.get(i).avg  > 40 && VOCDailyValues.get(i).avg  < 60) {
      aircolor[i] = okf;
    }
    if (VOCDailyValues.get(i).avg  > 60) {
      aircolor[i] = terriblef;
    }

    //water based on min
    if (waterDailyValues.get(i).min < 20) {
      watercolor[i] = clearf;
    }
    if (20 < waterDailyValues.get(i).min && waterDailyValues.get(i).min < 40) {
      watercolor[i] = cloudyf;
    }
    if (waterDailyValues.get(i).min > 40) {
      watercolor[i] = dirtyf;
    }

    //soil dry to moist based on min
    if (soilDailyValues.get(i).min < 20) {
      soilcolor[i] = badf;
    }
    if (20 < soilDailyValues.get(i).min &&  soilDailyValues.get(i).min < 40) {
      soilcolor[i] = goodf;
    }
    if (soilDailyValues.get(i).min > 40 && soilDailyValues.get(i).min < 60) {
      soilcolor[i] = okf;
    }
    if (soilDailyValues.get(i).min > 60) {
      soilcolor[i] = terriblef;
    }
  }
}

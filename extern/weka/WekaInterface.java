import weka.clusterers.InstancePair;
import weka.core.*;
import java.util.ArrayList;

/**
* This is a simple interface between Weka and MATLAB.
* It currently only implements functions required by mpckmeans.m
* It is based on the original MATLAB code by Tiago Gehring 
* Performing these tasks in Java rather than MATLAB is up to >1000x faster
*
* @author Mike Croucher
* @since  2016-01-25 
*/
public class WekaInterface {
    
public Instances WekaCreateInstances(double [] [] x, String name, String [] attr)
{
   /**
   * This method creates a set of weka instances from the MATLAB matrix x
   * The number of rows of x is the number of weka instances. 
   * @param x The input MATLAB matrix
   * @param name Name of the set of instances
   * @param attr Cell Array of Attribute names
   * @return Instances A weka Instances object.
   */
    int num_instances = x.length;
    int num_attributes  = x[0].length;
    
    /*Check that the number of attributes names is commensurate with columns of x */
    // TODO
    
    FastVector attr_vector = new FastVector();
    for(int i=0; i<num_attributes; i++)
    {
        Attribute attr_name = new Attribute(attr[i]);
        attr_vector.addElement(attr_name); 
    }
    
    //create an empty set of instances
    Instances output = new Instances(name, attr_vector, num_instances);
    
    for(int i = 0; i < num_instances;i++)
    {
        Instance this_instance = new Instance(1.0,x[i]);
        output.add(this_instance);    
    }
    
    return(output);
}

public ArrayList<InstancePair> WekaPrepareConstraints(int [] [] constr)
  {
   /**
   * This method creates an ArrayList of InstancePairs from the MATLAB matrix constr
   * @param constr MATLAB marix representing contsraints
   * @return ArrayList<InstancePair> ArrayList of weka InstancePairs
   */
    ArrayList<InstancePair> WekaConstraints = new ArrayList<InstancePair>();
    if (constr != null)
    {
        int rows = constr.length;
        int cols = constr[0].length;

        for(int i=0; i < rows; i++)
        {
            if(constr[i][0] < constr[i][1])
            {
                InstancePair pair = new InstancePair(constr[i][0] - 1, constr[i][1] - 1, InstancePair.MUST_LINK);
                WekaConstraints.add(pair);
            }
            else
            {
                InstancePair pair = new InstancePair(constr[i][1] - 1, constr[i][0] - 1, InstancePair.CANNOT_LINK);
                WekaConstraints.add(pair);
            }
        }
    }
    return(WekaConstraints);
  }

}


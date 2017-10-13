
/*
**
*/

//
// tt_crm - Used to generate Strongly Typed DataSet xsd file
//


namespace StrongTypesNS
{
    using System;
    using System.Data;


    public class tt_crmDS
    {

        static void Main (string[] args)
        {
            DataSet ds = new DataSet();
            DataRelation drel;
            DataColumn[] parentCols = null, childCols = null;
            DataColumn[] keyCols = null;

            ds.DataSetName = "tt_crm" + "DataSet";
            ds.Namespace = "tt_crm" + "NS";

            
	    DataTable tt_crm = ds.Tables.Add("tt_crm");
	    tt_crm.Columns.Add("opNo", typeof(int));
	    tt_crm.Columns.Add("opDesc", typeof(string));


            ds.WriteXmlSchema("tt_crm.xsd");

        }


    }
}

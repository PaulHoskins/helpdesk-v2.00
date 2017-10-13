
/*
**
**    Created by PROGRESS ProxyGen (Progress Version 11.6) Sat Oct 07 12:24:46 BST 2017
**
*/

//
// helpdesk
//




    using System;
    using Progress.Open4GL;
    using Progress.Open4GL.Exceptions;
    using Progress.Open4GL.Proxy;
    using Progress.Open4GL.DynamicAPI;
    using Progress.Common.EhnLog;
    using System.Collections.Specialized;
    using System.Configuration;

    /// <summary>
    /// 
    /// 
    /// 
    /// </summary>
    public class helpdesk : AppObject
    {
        private static int proxyGenVersion = 1;
        private const  int PROXY_VER = 5;

    // Create a MetaData object for each temp-table parm used in any and all methods.
    // Create a Schema object for each method call that has temp-table parms which
    // points to one or more temp-tables used in that method call.


	static DataTableMetaData getcrmlist_MetaData1;




        static helpdesk()
        {
		getcrmlist_MetaData1 = new DataTableMetaData(0, "tt_crm", 2, false, 0, null, null, null, "StrongTypesNS.tt_crmDataTable");
		getcrmlist_MetaData1.setFieldDesc(1, "opNo", 0, Parameter.PRO_INTEGER, 0, 0, 0, "", "", 0, null, "");
		getcrmlist_MetaData1.setFieldDesc(2, "opDesc", 0, Parameter.PRO_CHARACTER, 0, 1, 0, "", "", 0, null, "");


        }


    //---- Constructors
    public helpdesk(Connection connectObj) : this(connectObj, false)
    {       
    }
    
    // If useWebConfigFile = true, we are creating AppObject to use with Silverlight proxy
    public helpdesk(Connection connectObj, bool useWebConfigFile)
    {
        try
        {
            if (RunTimeProperties.DynamicApiVersion != PROXY_VER)
                throw new Open4GLException(WrongProxyVer, null);

            if ((connectObj.Url == null) || (connectObj.Url.Equals("")))
                connectObj.Url = "helpdesk_svc";

            if (useWebConfigFile == true)
                connectObj.GetWebConfigFileInfo("helpdesk");

            initAppObject("helpdesk_svc",
                          connectObj,
                          RunTimeProperties.tracer,
                          null, // requestID
                          proxyGenVersion);

        }
        catch (System.Exception e)
        {
            throw e;
        }
    }
   
    public helpdesk(string urlString,
                        string userId,
                        string password,
                        string appServerInfo)
    {
        Connection connectObj;

        try
        {
            if (RunTimeProperties.DynamicApiVersion != PROXY_VER)
                throw new Open4GLException(WrongProxyVer, null);

            connectObj = new Connection(urlString,
                                        userId,
                                        password,
                                        appServerInfo);

            initAppObject("helpdesk_svc",
                          connectObj,
                          RunTimeProperties.tracer,
                          null, // requestID
                          proxyGenVersion);

            /* release the connection since the connection object */
            /* is being destroyed.  the user can't do this        */
            connectObj.ReleaseConnection();

        }
        catch (System.Exception e)
        {
            throw e;
        }
    }


    public helpdesk(string userId,
                        string password,
                        string appServerInfo)
    {
        Connection connectObj;

        try
        {
            if (RunTimeProperties.DynamicApiVersion != PROXY_VER)
                throw new Open4GLException(WrongProxyVer, null);

            connectObj = new Connection("helpdesk_svc",
                                        userId,
                                        password,
                                        appServerInfo);

            initAppObject("helpdesk_svc",
                          connectObj,
                          RunTimeProperties.tracer,
                          null, // requestID
                          proxyGenVersion);

            /* release the connection since the connection object */
            /* is being destroyed.  the user can't do this        */
            connectObj.ReleaseConnection();
        }
        catch (System.Exception e)
        {
            throw e;
        }
    }

    public helpdesk()
    {
        Connection connectObj;

        try
        {
            if (RunTimeProperties.DynamicApiVersion != PROXY_VER)
                throw new Open4GLException(WrongProxyVer, null);

            connectObj = new Connection("helpdesk_svc",
                                        null,
                                        null,
                                        null);

            initAppObject("helpdesk_svc",
                          connectObj,
                          RunTimeProperties.tracer,
                          null, // requestID
                          proxyGenVersion);

            /* release the connection since the connection object */
            /* is being destroyed.  the user can't do this        */
            connectObj.ReleaseConnection();
        }
        catch (System.Exception e)
        {
            throw e;
        }
    }

        /// <summary>
	/// 
	/// </summary> 
	public string getcrmlist(out string pcToken, out bool plOk, out string pcMessage, out StrongTypesNS.tt_crmDataTable tt_crm)
	{
		RqContext rqCtx = null;
		if (isSessionAvailable() == false)
			throw new Open4GLException(NotAvailable, null);

		Object outValue;
		ParameterSet parms = new ParameterSet(4);

		// Set up input parameters


		// Set up input/output parameters


		// Set up Out parameters
		parms.setStringParameter(1, null, ParameterSet.OUTPUT);
		parms.setBooleanParameter(2, false, ParameterSet.OUTPUT, UnknownType.None);
		parms.setStringParameter(3, null, ParameterSet.OUTPUT);
		parms.setDataTableParameter(4, null, ParameterSet.OUTPUT, "StrongTypesNS.tt_crmDataTable");


		// Setup local MetaSchema if any params are tables
		MetaSchema getcrmlist_MetaSchema = new MetaSchema();
		getcrmlist_MetaSchema.addDataTableSchema(getcrmlist_MetaData1, 4, ParameterSet.OUTPUT);


		// Set up return type
		

		// Run procedure
		rqCtx = runProcedure("ws/getcrmlist.p", parms, getcrmlist_MetaSchema);


		// Get output parameters
		outValue = parms.getOutputParameter(1);
		pcToken = (string)outValue;
		outValue = parms.getOutputParameter(2);
		plOk = (bool)outValue;
		outValue = parms.getOutputParameter(3);
		pcMessage = (string)outValue;
		outValue = parms.getOutputParameter(4);
		tt_crm = (StrongTypesNS.tt_crmDataTable)outValue;


		if (rqCtx != null) rqCtx.Release();


		// Return output value
		return (string)(parms.ProcedureReturnValue);

	}

/// <summary>
	/// 
	/// </summary> 
	public string login(string pcLoginId, string pcPasswd, out bool plOk, out string pcMessage, out string pcToken)
	{
		RqContext rqCtx = null;
		if (isSessionAvailable() == false)
			throw new Open4GLException(NotAvailable, null);

		Object outValue;
		ParameterSet parms = new ParameterSet(5);

		// Set up input parameters
		parms.setStringParameter(1, pcLoginId, ParameterSet.INPUT);
		parms.setStringParameter(2, pcPasswd, ParameterSet.INPUT);


		// Set up input/output parameters


		// Set up Out parameters
		parms.setBooleanParameter(3, false, ParameterSet.OUTPUT, UnknownType.None);
		parms.setStringParameter(4, null, ParameterSet.OUTPUT);
		parms.setStringParameter(5, null, ParameterSet.OUTPUT);


		// Setup local MetaSchema if any params are tables



		// Set up return type
		

		// Run procedure
		rqCtx = runProcedure("ws/login.p", parms);


		// Get output parameters
		outValue = parms.getOutputParameter(3);
		plOk = (bool)outValue;
		outValue = parms.getOutputParameter(4);
		pcMessage = (string)outValue;
		outValue = parms.getOutputParameter(5);
		pcToken = (string)outValue;


		if (rqCtx != null) rqCtx.Release();


		// Return output value
		return (string)(parms.ProcedureReturnValue);

	}



    }



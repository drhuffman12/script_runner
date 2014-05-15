SELECT [maxattributeid]
      ,[attributeno]

      ,[objectname]
      ,[sameasobject]

      ,[attributename]
      ,[sameasattribute]
      
      ,[primarykeycolseq]
      ,[autokeyname]
      ,[canautonum]
      
      ,[alias]
      ,[columnname]
      
      ,[classname]

      ,[length]
      ,[scale]
      ,[maxtype]
      ,[mustbe]
      ,[required]
      ,[persistent]
      ,[defaultvalue]
      
      ,[eauditenabled]
      ,[esigenabled]
      
      ,[domainid]
      ,[entityname]
      ,[isldowner]
      ,[ispositive]
      ,[remarks]
      ,[title]
      ,[userdefined]
      ,[searchtype]
      ,[mlsupported]
      ,[mlinuse]
      ,[handlecolumnname]
      ,[rowstamp]
      ,[localizable]
      ,[restricted]
      ,[textdirection]
      ,[complexexpression]
  FROM [dbo].[maxattribute]
  WHERE 
      --[objectname] in ('po', 'a_po', 'poline', 'a_poline', 'postatus', 'assettrans', 'a_assettrans', 'matrectrans', 'a_matrectrans', 'matusetrans', 'a_matusetrans')
      [objectname] in ('crontaskdef', 'maxattribute', 'maxattributecfg', 'maxintobject', 'maxobject', 'maxobjectcfg', 'maxpresentation', 'maxrelationship', 'maxservice', 'maxsession', 'maxvars')
      --AND
      --[attributename] = 'vvv'
      AND
      (
		  [primarykeycolseq] IS NOT NULL
		  OR
		  [autokeyname] IS NOT NULL
		  OR
		  [canautonum] > 0
      )
      order by [objectname], [primarykeycolseq], [canautonum], [autokeyname]


select COUNT(*) from MATRECTRANS where MATRECTRANS.tolot is not null

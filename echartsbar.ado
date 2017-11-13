program define echartsbar
	version 14.0
	syntax varlist [if] [in] using/, [replace rotate(real) color(string) lengend(string) net]

	marksample touse, strok
	qui count if `touse'
	if `r(N)' == 0 exit 2000
	if !strpos(`"`using'"', ".") local using `"`using.html'"'

	if !ustrregexm(`"`using'"', "\.html$") {
		disp as error "the file generated must be a .html file"
		exit 198
	}
	
	if fileexists(`"`using'"') & "`replace'" == "" {
		disp as error "file `using' already exists"
		exit 602
	}
	else if fileexists(`"`using'"') {
		cap erase `"`using'"'
		if _rc != 0 {
			! del `"`using'"' /F
		}
	}

	if "`rotate'" == "" {
		scalar rotate = 90
	}
	else {
		scalar rotate = `rotate'
	}


	token `varlist'
	scalar num = `=wordcount("`varlist'")'
	forvalues i = 1/`=num' {
		local var`i' ="``i''"
		
		if strpos(`"`: type ``i'''"', "str") {
			disp as error "type mismatch, var`i' must be a numeric variable"
			exit 109
		}
	}

	if "`lengend'" == "" {
		local len = ""
		forvalues i= 1/`=num'{
			if `i' == `=num'{
				local len = `"`len''`var`i'''"'
			}
			else{
				local len = `"`len''`var`i''', "'
			}
			
		}		
	}
	else {
		token `lengend'
		local lnum = `=wordcount("`lengend'")'
		local len = ""
		forvalues i= 1/`lnum'{
			if `i' == `lnum'{
				local len = `"`len''``i'''"'
			}
			else{
				local len = `"`len''``i''', "'
			}
			
		}
	}



	if "`color'" != "" {
		token `color'
		local cnum = `=wordcount("`color'")'
		local col = ""
		forvalues i= 1/`cnum'{
			if `i' == `cnum'{
				local col = `"`col''``i'''"'
			}
			else{
				local col = `"`col''``i''', "'
			}
			
		}
	}


	if "`net'" == "" {
		if !ustrregexm(`"`using'"', "(/)|(\\)") {
			qui copy "`=c(sysdir_plus)'e/echarts.js" "./echarts.js", replace
			qui copy "`=c(sysdir_plus)'e/esl.js" "./esl.js", replace
			qui copy "`=c(sysdir_plus)'c/config.js" "./config.js", replace
		}
		else {
			if ustrregexm(`"`using'"', ".+((/)|(\\))") local path = ustrregexs(0)
			qui copy "`=c(sysdir_plus)'e/echarts.js" "`path'/echarts.js", replace
			qui copy "`=c(sysdir_plus)'e/esl.js" "`path'/esl.js", replace
			qui copy "`=c(sysdir_plus)'c/config.js" "`path'/config.js", replace
		}
	}
mata echartsbar(`"`using'"')
end


cap mata mata drop echartsbar()
mata
	function echartsbar(fileusing) {
		real scalar outputmap
		real scalar num
		real scalar i
		real scalar j
		real matrix var1

		var1 = st_data(., (st_local("var1")), st_local("touse"))

		num = st_numscalar("num")
		A = asarray_create() 

		for (i = 2; 2 <= num; i++) {
			asarray(A, sprintf("var%f", i),st_data(., (st_local("var"  + strofreal(i))), st_local("touse")))
		}
	

		outputmap = fopen(fileusing, "rw")
		fwrite(outputmap, sprintf(`"<html>\r\n"'))
		fwrite(outputmap, sprintf(`"\t<head>\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t<meta charset="utf-8">\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t<script src="esl.js"></script>\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t<script src="config.js"></script>\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t<meta name="viewport" content="width=device-width, initial-scale=1" />\r\n"'))
		fwrite(outputmap, sprintf(`"\t</head>\r\n"'))
		fwrite(outputmap, sprintf(`"\t<body>\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t<style>\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\thtml, body, #main {\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\twidth: %s;\r\n"',"100%"))
		fwrite(outputmap, sprintf(`"\t\t\t\theight: %s;\r\n"',"100%"))
		fwrite(outputmap, sprintf(`"\t\t\t\tmargin: 0;\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t}\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t#main {\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\twidth: 1000px;\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\tbackground: #fff;\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t}\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t</style>\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t<div id="main"></div>\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t<script>\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\trequire([\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t'echarts'\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t], function (echarts) {\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\tvar chart = echarts.init(document.getElementById('main'), null, {\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\trenderer: 'canvas'\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t});\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\tvar labelOption = {\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\tnormal: {\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\tshow: true,\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\tposition: 'insideBottom',\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\trotate: %g,\r\n"',st_numscalar("rotate")))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\ttextStyle: {\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\t\talign: 'left',\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\t\tverticalAlign: 'middle'\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\t}\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t}\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t};\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\toption = {\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\tcolor: [%s],\r\n"',st_local("col")))
		fwrite(outputmap, sprintf(`"\t\t\t\t\ttooltip: {\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\ttrigger: 'axis',\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\taxisPointer: {\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\t\ttype: 'shadow'\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\t}\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t},\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\tlegend: {\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\tdata:[%s]\r\n"',st_local("len")))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t},\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\ttoolbox: {\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\tshow: true,\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\torient: 'vertical',\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\tleft: 'right',\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\ttop: 'center',\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\tfeature: {\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\t\tmark: {show: true},\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\t\tdataView: {show: true, readOnly: false},\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\t\tmagicType: {show: true, type: ['line', 'bar', 'stack', 'tiled']},\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\t\trestore: {show: true},\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\t\tsaveAsImage: {show: true}\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\t}\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t},\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\tcalculable: true,\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\txAxis: [\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\t{\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\t\ttype: 'category',\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\t\taxisTick: {show: false},\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\t\tdata: ['%g'"',var1[1]))
		for (i = 1; i <= rows(var1); i++) {
			if (i != rows(var1)) fwrite(outputmap, sprintf(`"'%g', "',var1[i]))
			else fwrite(outputmap, sprintf(`"'%g'"',var1[i]))
		}
		fwrite(outputmap, sprintf(`"]\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\t}\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t],\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\tyAxis: [\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\t{\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\t\ttype: 'value'\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t\t}\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\t],\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t\tseries: [\r\n"'))


		for (j = 2 ; j <= num ; j++) {
			fwrite(outputmap, sprintf(`"\t\t\t\t\t{\r\n"'))
			fwrite(outputmap, sprintf(`"\t\t\t\t\t\t\tname: '%s',\r\n"',st_local(sprintf("var%g", j))))
			fwrite(outputmap, sprintf(`"\t\t\t\t\t\t\ttype: 'bar',\r\n"'))
			fwrite(outputmap, sprintf(`"\t\t\t\t\t\tbarGap: 0,\r\n"'))
			fwrite(outputmap, sprintf(`"\t\t\t\t\t\tlabel: labelOption,\r\n"'))
			fwrite(outputmap,sprintf(`"'%g'"',asarray(A, sprintf("var%f", j)[1,1]))
			for (2 = 1; i <= rows(var1); i++) {
				fwrite(outputmap, sprintf(`", '%g'"',asarray(A, sprintf("var%f", j)[i,1]))
			}
			fwrite(outputmap, sprintf(`"]\r\n"'))
			fwrite(outputmap, sprintf(`"\t\t\t\t\t},\r\n"'))		
		}

		

		fwrite(outputmap, sprintf(`"\t\t\t\t\t]\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\t}\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t\tchart.setOption(option);\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t });\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t</script>\r\n"'))
		fwrite(outputmap, sprintf(`"\t</body>\r\n"'))
		fwrite(outputmap, sprintf(`"</html>\r\n"'))
		fclose(outputmap)
	}
end


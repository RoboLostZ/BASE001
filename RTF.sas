
* Sorry guys, this isnt documented yet! Stay tuned.. it will be.;

resetline;
proc template; 
	define style Styles.RtfMod; 
 		parent = styles.rtf;

		style Body from Body "Controls the Body file." / 
 			marginbottom = 1in
 			margintop    = 1in 
 			marginright  = 1in 
 			marginleft   = 1in

 			'TitleFont2'          = ("Times New Roman, <serif>", 11pt, bold)  
 			'TitleFont'           = ("Times New Roman, <serif>", 13pt, bold)  
	 		'StrongFont'          = ("Times New Roman, <serif>", 11pt, bold)
	 		'headingEmphasisFont' = ("Times New Roman, <serif>", 11pt, bold) 
	 		'headingFont'         = ("Times New Roman, <serif>", 11pt, bold)
	 		'docFont'             = ("Times New Roman, <serif>", 10pt);
 
 		style table from output / 
 			rules = all 
 			frame = box
 			borderwidth   = 1pt 
 			borderspacing = 1pt 
 			bordercolor   = black 
 			background    = white 
 			cellpadding   = 2pt 
 			cellspacing   = 1pt;
 
 		style color_list from color_list "Colors used in the default style" / 
 			'link' = blue 
 			'bgH' = skyblue 
 			'fg' = black 
 			'bg' = white;

 		class prepage / 
 			cellwidth=5in 
 			just=center;

		style UserText from Note/ 
 			cellwidth=5in 
 			just=center
			outputwidth=100%
			protectspecialchars=off;
	 
 		class systemfooter / 
 			protectspecialchars=off;

 		style systemtitle from systemtitle / 
 			protectspecialchars=off;

	end;
run;

options mprint mlogic symbolgen orientation=landscape;
ods escapechar='^';
ods listing close;
ods rtf file="D:\sponsor\study_CRTDDS\define.rtf" startpage=no  style=RtfMod;
%let line=^R/RTF'\brdrb\brdrs\brdrw10\brsp20';			/* add a line */ 
%let head1=^R/RTF'\s1\fs26\b\qc ';                      /* Style 1, size=13pt, bold, center */ 
%let head2=^R/RTF'\s2\fs24\b\qc '; 						/* Style 2, size=12pt, bold, center */ 

/* Style 2, size=12pt, bold, center, page break */ 
%let head22=^R/RTF'\s2\fs24\b\qc\page '; 

%let keepn=^R/RTF'\keepn ';								/* keep with next */

/* define four headings in the RTF document as Styles 1 to 4 */  
%let heading4=%str({\s1 Heading 1;\s2 Heading 2;\s3 Heading 3;\s4 Heading 4;}); 

data study; 
 set study; 
 length stdytitle $200; 
 stdytitle="&head2.Study Information"; 
 call symput ('study',trim(studyname)); 
 call symput ('std',trim(StandardName)); 
 call symput ('stdv',trim(StandardVersion)); 
run; 
%put study = &study; 

%let docver=Data Definitions: CDISC SDTM 3.1.3;
title1 h=10pt j=l "Study &study.&line" j=r "&docver.&line";
footnote1 h=10pt j=c "&line" ; 
footnote2 h=10pt j=r "Page ^{pageof}"; 
 
ods rtf Text = "&head1.Study &study\line";
 
ods rtf prepage = "&head2.Study^\~Information"; 


proc report data = study nowd split='~' ; 
 column StudyName StudyDescription ; 
 define StudyName / display "Study Name" 
 style(column)=[cellwidth=1in just=left]; 
 define StudyDescription / display "Study Description" 
 style(column)=[cellwidth=5.0in just=left];
run;


ods rtf text = "&head2.Annotated Case Report Form"; 



data CRF;
length DocumentName $200; 
 set CRF;

/* {\field{\*\fldinst HYPERLINK "http://www.google.com/"}{\fldrslt http://www.google.com}} 
   {\field{\*\fldinst{HYPERLINK "http://www.google.com"}}{\fldrslt{\ul\cf1 http://www.google.com}}} */ 
 DocumentName = '{\field\*{\*\fldinst\*HYPERLINK\*"D:\\\\sponsor\\\\DXD_Loop\\\\blankcrf.pdf"}{\fldrslt\*{\cs15\cf2\ul blankcrf.pdf}}}';
run;

proc report data = CRF nowd; 
 column  title DocumentName  ; 
 define title / display "Title" 
 style(column)=[cellwidth=2in just=left]; 
 define DocumentName / display "Document Name" 
 style(column)=[cellwidth=4.0in just=left];
run;


ods rtf text = "&head22.Datasets";

proc report data = Domainxml nowd; 
 column  Dataset Description Class Structure Purpose Keys Location; 
 define Dataset / display "Dataset" 
 style(column)=[ just=left]; 
 define Description / display "Description" 
 style(column)=[ just=left];
 define Class / display "Class" 
 style(column)=[ just=left];
 define Structure / display "Structure" 
 style(column)=[ just=left];
 define Purpose / display "Purpose" 
 style(column)=[ just=left];
 define Keys / display "Keys" 
 style(column)=[ just=left];
 define Location / display "Location" 
 style(column)=[ just=left];
run;


%macro ds_table(dset=,desc=);
	data ds;
		length ct $100;
		set variablexml;
		where compress(dataset)="&dset";
		if valcode then ct=variable;
		else ct='';
	run;

	ods rtf text = "";

	ods rtf prepage = "&head2.&dset"; 
	proc report data=ds nowd split='~';  
	 columns ("^S={just=left}Dataset variables for &desc (&dset)"
				variable label type ct origin role comment); 
	 define variable / display "Variable" 
	 style(column)=[just=left]; 
	 define label / display "Label" 
	 style(column)=[just=left]; 
	 define type / display "Type" 
	 style(column)=[just=left]; 
	 define ct / display "Controlled~Terminology" 
	 style(column)=[just=left]; 
	 define origin / display "Origin" 
	 style(column)=[cellwidth=1in just=left];
	 define role / display "Role" 
	 style(column)=[ just=left]; 
	 define comment / display "Comment" 
	 style(column)=[just=left]; 
	run; 
	

%mend ds_table;

data _null_;
	set domainxml(keep=dataset description);
	call execute('%ds_table(dset=' || dataset || ',desc=' || description || ')');
run;


** Value Level Metadata section;
** Temp1 contains the datasets that we are interested in and;
** they are in the correct order;

ods rtf Text = "&head1.Value Level Metadata\line";


%macro valevmet(dset=,desc=);

proc report data = vallist nowd split='~';
	where compress(dataset)="&dset";
 columns ("^S={just=center}&desc (&dset) Value List"
				variable value label type ct origin valcomm);
 define variable / display "Variable"         style(column)=[ just=left]; 
 define label / display "Label"               style(column)=[cellwidth=1.5in just=left]; 
 define type / display "Type"                 style(column)=[cellwidth=0.5in just=left]; 
 define ct / computed "Controlled~Terminology" style(column)=[cellwidth=1.0in just=left]; 
 define origin / display "Origin"             style(column)=[cellwidth=0.6in just=left]; 
 define valcomm / display "Comment"           style(column)=[cellwidth=2in just=left];
 compute ct / length=8;
  ct = " ";
 endcomp;
run; 

%mend;

* Join the domain descriptions
* Cant do a dataset merge because we need to preserve the current sort order;
proc sql;
	create table temp2 as
	select compress(t1.dataset) as dataset, dx.description
	from temp1 as t1, domainxml as dx
	where compress(t1.dataset)=compress(dx.dataset);
quit;


data _null_;
	set temp2;
	call execute('%valevmet(dset=' || dataset || ',desc=' || description || ')');
run;


ods rtf Text = "&head1.Controlled Terminology\line";
 
ods rtf prepage = "&head2.CodeLists"; 

proc report data = cdlst nowd split='~';
 columns (format value code);
 define format / order "Reference~Name"       style(column)=[cellwidth=1in just=left]; 
 define value / display "Code Value"          style(column)=[cellwidth=3in just=left]; 
 define code / display "Code Text"            style(column)=[cellwidth=3in just=left];
 break after format / skip;
run;



ods rtf close;

ods html close; ods html;


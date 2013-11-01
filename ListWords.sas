%*;/*
\begin{lstlisting}[language=SAS,caption=ListWords.sas,label=listwords.sas]
*/
/*
ListWords.sas  program to list all the words in the cause-of-death literals
               of poisoning records.

*/
libname sm  'c:\data\poisoning\SuperMICAR';

%include "c:\user\poisoning\SuperMICAR\spell.sas";
%include "c:\user\poisoning\SuperMICAR\generic.sas";

/*
Procedure to convert literal entries to individual words

1. Combine the literals into one string
2. Divide string into words.
3. Remove all punctuation from each word
4. Correct spelling with the "spell" format
5. Convert brand names to their generic equivalent
6. Use do loop to put each word into a separate field.
*/

%let datayear = 2004;
data temp1;
   length literal $ 970;
   set sm.wa&datayear.poison;
   Year = put(year(dth_date),4.);
   literal = trim(linea)||" "||trim(lineb)||" "||trim(linec)||" "||trim(lined)||" "
              ||trim(lineother)||" "||trim(descrip);

   array words{75} $ 35 worda1-worda75;

   j = 0;
   do i = 1 to 75;
      j = j+1;
      words{i} = scan(literal,j," .<(+&!$*);^-/,%|\`=:[]");
      words{i} = compress(words{i},"'");
      words{i} = put(words{i}, $spell.);
/*
If a combo contains the words 'I' and 'V' consecutively, then
combine them into one word.  Adjust the value of i in order to
count the words correctly for these cases.

If a word is preceded by any of the words NON, NOT, or NO, then
combine the two words with a space between. Adjust the word count.

Combine CARBON, NITROUS, POLY, DESMETHYL, ISOPROPYL, or METHYL with 
the following word, with a space between.

Combine DEXTRO with the following word, without a space between.

Combine DECANOATE or SULFATE with the previous word, with a space between.

If CHLORAL is followed by HYDRATE, combine them into one entry.
If COCA is followed by ETHYLENE, combine them into one entry.
If ETHYL is followed by ALCOHOL, combine them into one entry.
If ETHEL is followed by ALCOHOL, combine them, and spell it ETHYL ALCOHOL.
If ETHYL is followed by CHLORIDE, combine them into one entry.
If VALPROIC is followed by ACID, combine them into one entry.
If SALICYLIC is followed by ACID, combine them into one entry.
If DICHLOROPHENOXYACETIC is followed by ACID, combine them into one entry.
if PAIN is followed by RELIEVER or RELIEVERS, combine them.
if MUSCLE is followed by RELAXANTS, RELAXANT, RELAXER, or RELAXERS, combine them.
if FEN is followed by PHEN, combine them
if BETA is followed by BLOCKER or BLOCKERS, combine them
if FLUORINATED is followed by HYDROCARBON, combine them

other words to combine:
HYDROGEN SULFIDE
HYDROGEN CHLORIDE
GAMMA HYDROXYBUTYRATE (first combine HYDROXY BUTYRATE if they are separate)
CALCIUM CHANNEL BLOCKER
MS CONTIN
DES METHYL (no space between)
METHYLENE DIOXYMETHAMPHETAMINE (no space between)
MIS HAP (no space between)
DILTIAZEM HYDROCHLORIDE
OXALIC ACID
GABA and PENTIN (no space between)
SULFURIC ACID
CAR EXHAUST
ENGINE EXHAUST
VEHICLE EXHAUST
AUTO EXHAUST
AUTOMOBILE EXHAUST
PRODUCTS OF COMBUSTION
GASOLINE VAPOR
SMOKE INHALATION
COMPRESSED NITROGEN
INERT GAS
NATURAL GAS
COMPRESSED AIR
FK 506 (no space)
ETHYLENE GLYCOL

*/
      X = 0;
      if i ge 2 and words{i} ne "                    " then do;
         if words{i} = "V" and words{i-1} = "I" then do;
            words{i-1} = compress(words{i-1}||words{i});
            X = 1;
            end;
         if  words{i-1} in ("NON","NOT","NO") then do;
            words{i-1} = trim(words{i-1})||" "||trim(words{i});
            X = 1;
            end;
         if  words{i-1} in ("CARBON","NITROUS","POLY","DESMETHYL","ISOPROPYL",
               "METHYL") then do;
            words{i-1} = trim(words{i-1})||" "||trim(words{i});
            X = 1;
            end;
         if  words{i-1} = "DEXTRO" then do;
            words{i-1} = trim(words{i-1})||trim(words{i});
            X = 1;
            end;
         if words{i} in ("DECANOATE","SULFATE") then do;
            words{i-1} = trim(words{i-1})||" "||trim(words{i});
            X = 1;
            end;
         if words{i} = "ALCOHOL" and words{i-1} = "ETHYL" then do;
            words{i-1} = trim(words{i-1})||" "||trim(words{i});
            X = 1;
            end;
         if words{i} = "ALCOHOL" and words{i-1} = "ETHEL" then do;
            words{i-1} = "ETHYL ALCOHOL";
            X = 1;
            end;
         if words{i} = "HYDRATE" and words{i-1} = "CHLORAL" then do;
            words{i-1} = trim(words{i-1})||" "||trim(words{i});
            X = 1;
            end;
         if words{i} = "ETHYLENE" and words{i-1} = "COCA" then do;
            words{i-1} = trim(words{i-1})||" "||trim(words{i});
            X = 1;
            end;
         if words{i} = "CHLORIDE" and words{i-1} = "ETHYL" then do;
            words{i-1} = trim(words{i-1})||" "||trim(words{i});
            X = 1;
            end;
         if words{i} = "ACID" and words{i-1} = "VALPROIC" then do;
            words{i-1} = trim(words{i-1})||" "||trim(words{i});
            X = 1;
            end;
         if words{i} = "ACID" and words{i-1} = "SALICYLIC" then do;
            words{i-1} = trim(words{i-1})||" "||trim(words{i});
            X = 1;
            end;
         if words{i} = "ACID" and words{i-1} = "DICHLOROPHENOXYACETIC" then do;
            words{i-1} = trim(words{i-1})||" "||trim(words{i});
            X = 1;
            end;
         if words{i} = "EXHAUST" and words{i-1} in ("CAR","ENGINE","VEHICLE",
               "AUTO","AUTOMOBILE") then do;
            words{i-1} = trim(words{i-1})||" "||trim(words{i});
            X = 1;
            end;
         if words{i} in ("RELIEVER","RELIEVERS") and words{i-1} = "PAIN" then do;
            words{i-1} = trim(words{i-1})||" "||trim(words{i});
            X = 1;
            end;
         if words{i} in ("RELAXANTS","RELAXER","RELAXANT","RELAXERS") and
               words{i-1} = "MUSCLE" then do;
            words{i-1} = trim(words{i-1})||" "||trim(words{i});
            X = 1;
            end;
         if words{i} = "PHEN" and words{i-1} = "FEN" then do;
            words{i-1} = trim(words{i-1})||"-"||trim(words{i});
            X = 1;
            end;
         if words{i} in ("BLOCKER","BLOCKERS") and words{i-1} = "BETA" then do;
            words{i-1} = trim(words{i-1})||"-"||trim(words{i});
            X = 1;
            end;
         if words{i} = "HYDROCARBON" and words{i-1} = "FLUORINATED" then do;
            words{i-1} = trim(words{i-1})||" "||trim(words{i});
            X = 1;
            end;
         if words{i} = "SULFIDE" and words{i-1} = "HYDROGEN" then do;
            words{i-1} = trim(words{i-1})||" "||trim(words{i});
            X = 1;
            end;
         if words{i} = "CHLORIDE" and words{i-1} = "HYDROGEN" then do;
            words{i-1} = trim(words{i-1})||" "||trim(words{i});
            X = 1;
            end;
         if words{i} in ("BUTYRATE","BUTYRIC") and words{i-1} = "HYDROXY" then do;
            words{i-1} = trim(words{i-1})||trim(words{i});
            X = 1;
            if i ge 3 then do;
               if words{i-1} in ("HYDROXYBUTYRATE","HYDROXYBUTYRIC") and
                     words{i-2} = "GAMMA" then do;
                  words{i-2} = trim(words{i-2})||" "||trim(words{i-1});
                  X = 2;
                  end;
               end;
            end;
         if words{i} in ("HYDROXYBUTYRATE","HYDROXYBUTYRIC") and
               words{i-1} = "GAMMA" then do;
            words{i-1} = trim(words{i-1})||" "||trim(words{i});
            X = 1;
            end;
         if words{i} = "ACID" and words{i-1} = "GAMMA HYDROXYBUTYRIC" then do;
            words{i-1} = trim(words{i-1})||" "||trim(words{i});
            X = 1;
            end;
         if words{i} = "CONTIN" and words{i-1} = "MS" then do;
            words{i-1} = trim(words{i-1})||" "||trim(words{i});
            X = 1;
            end;
         if words{i} = "METHYL" and words{i-1} = "DES" then do;
            words{i-1} = trim(words{i-1})||trim(words{i});
            X = 1;
            end;
         if words{i} = "DIOXYMETHAMPHETAMINE" and words{i-1} = "METHYLENE" then do;
            words{i-1} = trim(words{i-1})||trim(words{i});
            X = 1;
            end;
         if words{i} = "HAP" and words{i-1} = "MIS" then do;
            words{i-1} = trim(words{i-1})||trim(words{i});
            X = 1;
            end;
         if words{i} = "HYDROCHLORIDE" and words{i-1} = "DILTIAZEM" then do;
            words{i-1} = trim(words{i-1})||" "||trim(words{i});
            X = 1;
            end;
         if words{i} = "ACID" and words{i-1} = "OXALIC" then do;
            words{i-1} = trim(words{i-1})||" "||trim(words{i});
            X = 1;
            end;
         if words{i} = "ACID" and words{i-1} = "SULFURIC" then do;
            words{i-1} = trim(words{i-1})||" "||trim(words{i});
            X = 1;
            end;
         if words{i} = "VAPOR" and words{i-1} = "GASOLINE" then do;
            words{i-1} = trim(words{i-1})||" "||trim(words{i});
            X = 1;
            end;
         if words{i} = "PENTIN" and words{i-1} = "GABA" then do;
            words{i-1} = "GABAPENTIN";
            X = 1;
            end;
         if words{i} = "INHALATION" and words{i-1} = "SMOKE" then do;
            words{i-1} = trim(words{i-1})||" "||trim(words{i});
            X = 1;
            end;
         if words{i} = "GAS" and words{i-1} in ("INERT","NATURAL") then do;
            words{i-1} = trim(words{i-1})||" "||trim(words{i});
            X = 1;
            end;
         if words{i} in ("AIR","NITROGEN") and words{i-1} = "COMPRESSED" then do;
            words{i-1} = trim(words{i-1})||" "||trim(words{i});
            X = 1;
            end;
         if words{i} = "506" and words{i-1} = "FK" then do;
            words{i-1} = trim(words{i-1})||trim(words{i});
            X = 1;
            end;
	 if words{i} = "GLYCOL" and words{i-1} = "ETHYLENE" then do;
            words{i-1} = trim(words{i-1})||" "||trim(words{i});
            X = 1;
            end;
         end;

      if i ge 3 and words{i} ne "                    " then do;
         if words{i} in ("BLOCKER","BLOCKERS") and words{i-1} = "CHANNEL" and
               words{i-2} = "CALCIUM" then do;
            words{i-2} = trim(words{i-2})||" "||trim(words{i-1})||" "||trim(words{i});
            X = 2;
            end;
         if words{i} = ("COMBUSTION") and words{i-1} = "OF" and
               words{i-2} = "PRODUCTS" then do;
            words{i-2} = trim(words{i-2})||" "||trim(words{i-1})||" "||trim(words{i});
            X = 2;
            end;
         end;
/*
If we have formed all the separate words, then output them:
*/
      if words{i} = "                    " and i le 75 then do;
         nword = i-1;
         output temp1;
         return;
         end;
      if i = 75 then do;
         nword = 75;
         output temp1;
         end;
      if X = 1 then i = i-1;
      if X = 2 then i = i-2;
      end /* end do i = 1 to 75*/;
run;

/*
Procedure to put each word on a separate record:
Read temp1 and output each individual word to a new record.
Create a new field (word_generic) which has brand names converted to generic name.
*/
data temp2(keep=certno word underly underly3 word_generic);
   length word word_generic $ 35;
   set temp1;

   array words{75} $ 35 worda1-worda75;

   do i = 1 to 75;
      word = put(words{i}, $spell.);
      word_generic = put(word, $genname.);
      if word ne "" then output temp2;
/*
If we have output all the separate words, then go to next case:
*/
      if words{i} = "                    " and i le 75 then return;
      if i = 75 then return;
      end /* end do i = 1 to 75*/;
run;
/*
Unduplicate the drug words within certificates.
*/
Proc sort data=temp2 out=temp3 nodupkey;
   by certno word;
run;

proc sort data=temp3;
   by word;
run;

/*
Read in the drug word list.
*/
data drugword;
   infile 'c:\user\poisoning\supermicar\drugword.lst' pad;
   if _n_ = 1 then input ////////;
   input @1 word $char35.;
run;
proc sort data=drugword nodupkey;
   by word;
run;
/*
Read in the non-drug word list.
*/
data nondrugword;
   infile 'c:\user\poisoning\supermicar\nondrugword.lst' pad;
   if _n_ = 1 then input ////////;
   input @1 word $char35.;
run;
proc sort data=nondrugword nodupkey;
   by word;
run;

/*
Washington 2003:

Now merge the dataset with the list of drug words in DrugWords.lst, and
then do a frequency count.

Keep only the words that are also on the drugwords list.
*/
data sm.wa2003drug wa2003nondrug wa2003unknown;
   merge temp3(in=indeaths) drugword(in=indrug) nondrugword(in=innondrug);
   by word;
   state = 'Wa ';
   if (indeaths and indrug)      then output sm.wa2003drug;
   if (indeaths and innondrug)   then output wa2003nondrug;
   if (indeaths and (not indrug) and (not innondrug)) then output wa2003unknown;
run;
/*
California 2003:
I will merge the California 2003 words with the drug word list and the non drug
word list in turn. Then I will print out the words that don't match and review
them in order to classify them as drug or non-drug words. Then I will revise
the drug and non-drug lists and repeat the process.

*/
data cal2003drug cal2003nondrug cal2003unknown;
   merge temp3(in=incal) drugword(in=indrug) nondrugword(in=innondrug);
   by word;
   state = 'Cal';
   if (incal and indrug)      then output cal2003drug;
   if (incal and innondrug)   then output cal2003nondrug;
   if (incal and (not indrug) and (not innondrug)) then output cal2003unknown;
run;

options ps=200 ls=80;
proc freq data=calunknown;
   tables word;
run;

/*
Washington 2004-2010:
Merge the words with the drug word list and the non-drug word list. Print out the
words that don't match. and review them.
*/
data sm.wa&datayear.drug wa&datayear.nondrug wa&datayear.unknown;
   merge temp3(in=inwa) drugword(in=indrug) nondrugword(in=innondrug);
   by word;
   state = 'Wa ';
   if (inwa and indrug)      then output sm.wa&datayear.drug;
   if (inwa and innondrug)   then output wa&datayear.nondrug;
   if (inwa and (not indrug) and (not innondrug)) then output wa&datayear.unknown;
run;

options ps=200 ls=80;
proc freq data=wa&datayear.unknown;
   tables word;
run;

/*
California 2002:
I will merge the California 2002 words with the drug word list and the non drug
word list in turn. Then I will print out the words that don't match and review
them in order to classify them as drug or non-drug words. Then I will revise
the drug and non-drug lists and repeat the process.

*/
data cal2002drug cal2002nondrug cal2002unknown;
   merge temp3(in=incal) drugword(in=indrug) nondrugword(in=innondrug);
   by word;
   state = 'Cal';
   if (incal and indrug)      then output cal2002drug;
   if (incal and innondrug)   then output cal2002nondrug;
   if (incal and (not indrug) and (not innondrug)) then output cal2002unknown;
run;

options ps=200 ls=80;
proc freq data=calunknown;
   tables word;
run;

/*
Combine the datasets

old:
data sm.PoisonWords;
   length year $ 4;
   set wa2003drug wa2004drug cal2002drug cal2003drug sm.wa2005drug sm.wa2006drug
       sm.wa2007drug sm.wa2008drug sm.wa2009drug sm.wa2010drug;
   year = substr(certno,1,4);
run;
proc sort data=sm.PoisonWords;
   by certno;
run;
*/

data sm.WAdrugWords;
   length year $ 4;
   set sm.wa2003drug sm.wa2004drug sm.wa2005drug sm.wa2006drug sm.wa2007drug
       sm.wa2008drug sm.wa2009drug sm.wa2010drug;
   year = substr(certno,1,4);
run;
proc sort data=sm.wadrugWords;
   by certno;
run;

/*
Use the $gencat format to classify drug words.

Classify each drug word as a generic drug name or a common name for some other
substance.
*/
data temp5;
   set temp4;
   class = put(word, $gencat.);
run;

proc freq data=temp5;
   tables word/out=list;
run;
proc sort data=list;
   by descending count;
run;
options ps=50;
/*
\end{lstlisting}
*/


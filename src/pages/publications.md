@def title = "Publications"
@def hascode = false

~~~
<div>
<div style="float: left">
<a href=https://scholar.google.com/citations?user=Fe9XuEEAAAAJ><img src="http://am-one.ru/wp-content/uploads/2015/07/Google-Scholar-logo.png" alt="Google Scholar" style="max-width:48px; max-height:48px; width=auto; height=auto"></a>
</div>
<div style="float: left">
<a href=https://www.researchgate.net/profile/Benoit_Legat2><img src="https://www.researchgate.net/apple-touch-icon-180x180.png" alt="Research Gate" style="max-width:36px; max-height:36px; width=auto; height=auto; position:relative;left:-10px; top:5px;"></a>
</div>
</div>
<div style="clear: both"></div>
~~~

## Table of contents

Set Programming
**Talks**: [[2019_JuMP]](#2019_JuMP) [[2018_NCAG]](#2018_NCAG)
* solved using Sum-of-Squares Programming
  **Talks**: [[2018_JuMP]](#2018_JuMP) [[2017_JuMP]](#2017_JuMP) **Posters**: [[2018_NCAG]](#2018_NCAG_poster)
  - with controlled or algebraic invariance constraints
    **Talks**: [[2018_ADHS: application to MPC]](#2018_ADHS) [[2018_ISMP: application to Stochastic Programming]](#2018_ISMP) [[2018_BNLM]](#2018_BNLM)
  - Certifying infeasibility
    **Papers**: [[2019_TAC]](#2019_TAC) **Talks**: [[2017_BNLM]](#2017_BNLM) [[2017_UCLA]](#2017_UCLA) [[2016_CTUP]](#2016_CTUP)
    * Stabilization of Switched Systems applied to adaptative (co-)simulation
      **Talks**: [[2018_CDC]](#2018_CDC) [[2018_UANT]](#2018_UANT) **Posters**: [[2018_ADHS]](#2018_ADHS_poster)
* solved using Dual Dynamic Programming applied to the Entropic Cone
  **Talks**: [[2017_ENPC]](#2017_ENPC) [[2016_SITB]](#2016_SITB)


## Papers and proceedings

~~~
<ul>
  <li>
    Benoît Legat, Pablo A. Parrilo, and Raphaël M. Jungers. <strong>Certifying unstability of Switched Systems using Sum of Squares Programming</strong>. Submitted to SICON.<br><a href="https://arxiv.org/abs/1710.01814">arXiv</a> <a href="https://drive.google.com/open?id=0B1axlYz3_XXKd0lTektfekU2eGc">pdf</a> <a href="https://github.com/blegat/SwitchOnSafety.jl/blob/master/examples/LPJ17.ipynb">code</a>
  </li>
  <li id="2019_TAC">
    Benoît Legat, Pablo A. Parrilo and Raphael M. Jungers. <strong><a href="https://ieeexplore.ieee.org/abstract/document/8657769">An entropy-based bound for the computational complexity of a switched system</a></strong>. <em>IEEE Transactions on Automatic Control (TAC)</em>, 2019<br><a href="https://doi.org/10.24433/CO.0452244.v1">codeocean</a>
  </li>
  <li>
    Cláudio Gomes, Raphaël M. Jungers, Benoît Legat, and Hans Vangheluwe. <strong><a href="https://ieeexplore.ieee.org/abstract/document/8619223">Minimally, Constrained Stable Switched Systems and Application to Co-Simulation</a></strong>. <em>IEEE Conference on Decision and Control (CDC)</em>, 2018, pp. 5676-5681.<br><a href="https://arxiv.org/abs/1809.02648">arXiv</a>
  </li>
  <li>
    Benoît Legat, Paulo Tabuada and Raphaël Jungers. <strong><a href="https://www.sciencedirect.com/science/article/pii/S2405896318311480">Computing controlled invariant sets for hybrid systems with applications to model-predictive control</a></strong>. <em>IFAC Conference on Analysis and Design of Hybrid Systems</em>, 2018.<br><a href="https://arxiv.org/abs/1802.04522">arXiv</a> <a href="https://github.com/blegat/SwitchOnSafety.jl">code</a>
  </li>
  <li>
    Manon Martin, Benoît Legat, Justine Leenders, Julien Vanwinsberghe, Réjane Rousseau, Bruno Boulanger, Paul H.C. Eilers, Pascal De Tullio and Bernadette Govaerts. <strong><a href="https://www.sciencedirect.com/science/article/pii/S0003267018303490">PepsNMR for 1H-NMR metabolomic data pre-processing</a></strong>. <em>Analytica Chimica Acta</em>, 2018.<br><a href="https://github.com/ManonMartin/PepsNMR">code</a>
  </li>
  <li>
    Cláudio Gomes, Benoît Legat, Raphaël M. Jungers and Hans Vangheluwe. <strong>Stable Adaptive Co-simulation: A Switched Systems Approach</strong>. <em>IUTAM Symposium on Co-Simulation and Solver Coupling</em>, 2017.
  </li>
  <li>
    Benoît Legat, Raphaël M. Jungers. <a href="http://sites.uclouvain.be/sitb2016/Proceedings_SITB2016_preliminary.pdf"><strong>Parallel optimization on the Entropic Cone</strong></a>. <em>37rd Symposium on Information Theory in the Benelux</em>, 2016.<br><a href="https://drive.google.com/open?id=0B1axlYz3_XXKNTRjZTVuSmtWTXM">pdf</a> <a href="https://github.com/blegat/EntropicCone.jl">code</a> <a href="https://drive.google.com/open?id=0B1axlYz3_XXKa3BXZTlsdUJJZzA">slides</a>
  </li>
  <li>
    Benoît Legat, Raphaël M. Jungers, and Pablo A. Parrilo. <a href=http://dl.acm.org/citation.cfm?id=2883821><strong>Generating Unstable Trajectories for Switched Systems via Dual Sum-Of-Squares Techniques</strong></a>. <em>19th International Conference on Hybrid Systems: Computation and Control</em>. ACM, 2016.<br><a href="https://drive.google.com/open?id=0B1axlYz3_XXKeGRabkFCN3R0Y00">pdf</a> <a href="https://github.com/blegat/RPHSCC2016">code</a> <a href="https://drive.google.com/open?id=0B1axlYz3_XXKNm13eWU5R3E1RVE">slides</a>
  </li>
</ul>
~~~

## Talks

### Upcoming

~~~
<ul>
  <li id="2019_NSIDE"><a href="https://www.n-side.com/">N-SIDE</a>, October 2019</li>
</ul>
~~~

### Past

~~~
<ul>
  <li id="2019_BJUG">
    <a href="https://julia-users-berlin.github.io/">Berlin Julia Users Group</a>, August 2019<br><a href="https://drive.google.com/open?id=1NjavuhxE9OrhF8BEht2vlYrQ39hvhgpt">slides</a>
  </li>
  <li id="2019_ICCOPT">
    <a href="https://iccopt2019.berlin/">ICCOPT 2019</a>, August 2019<br><a href="https://drive.google.com/open?id=1BjhlfXI7CmgbUf87gw9BO4G-3BeOwNoj">slides</a>
  </li>
  <li id="2019_JuliaCon">
    <a href="https://juliacon.org/2019/">JuliaCon 2019</a>, July 2019<br><a href="https://drive.google.com/open?id=1HiA-praFyejE0Z3nVSpFEv938TAcPjA9">slides</a> <a href="https://www.youtube.com/watch?v=cTmqmPcroFo">video</a>
  </li>
  <li id="2019_LANL">
    <a href="https://cnls.lanl.gov/External/showtalksummary.php?selection=7768">Los Alamos National Institute (LANL), Center for Nonlinear Studies (CNLS) 2019</a>, July 2019<br><a href="https://drive.google.com/open?id=1kNF18C7RY2zi7jcZBMO1PRXtHuvVTFPn">slides</a>
  </li>
  <li id="2019_EURO">
    <a href="https://www.euro2019dublin.com/">European Conference in Operational Research 2019</a>, June 2019.<br><a href="https://drive.google.com/open?id=1Wry56NzzL4QBRSwuhP4AlKOe2i2FL7dk">slides</a>
  </li>
  <li id="2019_JuliaNantes">
    <a href="https://julialang.univ-nantes.fr/programme/">juliaday Nantes 2019</a>, June 2019.<br><a href="https://drive.google.com/open?id=1pN3G9Pr8jbzK9EEaJ9a6p_qKwSbxb2bo">slides</a>
  </li>
  <li id="2019_JuMP">
    <a href="https://www.juliaopt.org/meetings/santiago2019/">JuMP-dev 2019</a>, March 2019.<br><a href="https://www.juliaopt.org/meetings/santiago2019/slides/benoit_legat.pdf">slides</a> <a href="https://www.youtube.com/watch?v=hV3G-eNLNjk">video</a>
  </li>
  <li id="2018_CDC">
    <a href="https://cdc2018.ieeecss.org/">57th IEEE Conference on Decision and Control</a>, December 2018.<br><a href="https://drive.google.com/open?id=1Ek2UmU4zTb5BUyhcMquFVAlJNbLwsVy-">slides</a>
  </li>
  <li id="2018_NCAG">
    <a href="https://www.mis.mpg.de/calendar/conferences/2018/nc2018/program.html">Summer School on Numerical Computing in Algebraic Geometry</a>, August 2018.
  </li>
  <li id="2018_ADHS">
    <a href="https://www.cs.ox.ac.uk/conferences/ADHS18/"><em>IFAC Conference on Analysis and Design of Hybrid Systems</em></a>, July 2018.<br><a href="https://drive.google.com/open?id=1CA91yuYViQkG1A37ktRkTk5ZgDy7zisp">slides</a> <a href="https://github.com/JuliaPolyhedra/Polyhedra.jl/blob/master/examples/Computing%20controlled%20invariant%20sets.ipynb">code</a>
  </li>
  <li id="2018_ISMP">
    <a href="https://ismp2018.sciencesconf.org/"><em>23rd International Symposium on Mathematical Programming</em></a>, July 2018.<br><a href="https://drive.google.com/open?id=1JyhySuDRH36CYy41YuTgEMZcc0fw_6Lm">slides</a> <a href="https://github.com/blegat/SwitchOnSafety.jl/blob/master/examples/reservoir.ipynb">code</a>
  </li>
  <li id="2018_JuMP">
    <strong>Automatic reformulation using constraint bridges</strong>. <a href="http://www.juliaopt.org/meetings/bordeaux2018/"><em>JuMP-dev workshop 2018</em></a>, June 2018.<br><a href="http://www.juliaopt.org/meetings/bordeaux2018/legat.pdf">slides</a> <a href="https://github.com/JuliaOpt/MathOptInterface.jl/tree/master/src/Bridges">code</a>
  </li>
  <li id="2018_BNLM">
    <a href="http://www.beneluxmeeting.nl/2018/"><em>37th Benelux Meeting on Systems and Control</em></a>, March 2018.<br><a href="https://drive.google.com/open?id=1f2qtwBMXt5Ma-0EAjiy35fLbPIWXvloN">slides</a>
  </li>
  <li id="2018_UANT">
    <a href="https://www.uantwerpen.be/images/uantwerpen/personalpage33566/files/AG-Seminar-2018ss/2018-02-19-Legat.pdf"><em>UAntwerpen</em></a>, February 2018.<br><a href="https://drive.google.com/open?id=1n5NRpzpYX9moejqdghNcPuaEspP9M2Zp">slides</a>
  </li>
  <li id="2017_JuMP">
    <a href="http://www.juliaopt.org/meetings/mit2017/"><em>JuMP-dev workshop 2017</em></a>, June 2017.<br><a href="http://www.juliaopt.org/meetings/mit2017/legat.pdf">slides</a> <a href="https://www.youtube.com/watch?v=kyo72yWYr54&feature=youtu.be">video</a>
  </li>
  <li id="2017_ENPC">
    <em>Ecole des Ponts</em>, June 2017.<br><a href="https://drive.google.com/open?id=0B1axlYz3_XXKM0pTNEphcy0wY2c">slides</a>
  </li>
  <li id="2017_BNLM">
    <a href="http://www.beneluxmeeting.nl/2017/"><em>36th Benelux Meeting on Systems and Control</em></a>, March 2017.<br><a href="https://drive.google.com/open?id=0B1axlYz3_XXKQ3d0TzZXTFB6NXc">pdf</a> <a href="https://drive.google.com/open?id=0B1axlYz3_XXKT1hMNFJFMXItUlk">slides</a>
  </li>
  <li id="2017_UCLA">
    <em>UCLA Electrical Engineering Dept.</em>, March 2017.<br><a href="https://drive.google.com/open?id=0B1axlYz3_XXKdmlIQmNrWjJvZGs">slides</a>
  </li>
  <li id="2016_CTUP">
    <a href="http://aa4cc.dce.fel.cvut.cz/content/benoit-legat-phd-student-ucl-extracting-unstable-trajectories-switched-systems-measures"><em>Czech Technical University in Prague</em></a>, November 2016.<br><a href="https://drive.google.com/open?id=0B1axlYz3_XXKbzloNVA5bDFveUE">slides</a>
  </li>
  <li id="2016_SITB">
    <a href="https://sites.uclouvain.be/sitb2016/">37rd Symposium on Information Theory in the Benelux</a>, May 2016.<br><a href="https://drive.google.com/open?id=0B1axlYz3_XXKa3BXZTlsdUJJZzA">slides</a>
  </li>
  <li id="2016_HSCC">
    <a href="http://www.cs.ox.ac.uk/conferences/hscc2016/">19th ACM International Conference on Hybrid Systems: Computation and Control</a>, April 2016.<br><a href="https://drive.google.com/open?id=0B1axlYz3_XXKNm13eWU5R3E1RVE">slides</a>
  </li>
</ul>
~~~

## Posters

~~~
<ul>
  <li id="2018_NCAG_poster">
    <a href="https://www.mis.mpg.de/calendar/conferences/2018/nc2018.html">Summer School on Numerical Computing in Algebraic Geometry</a>, August 2018.<br><a href="https://drive.google.com/open?id=1pf9rdoVEjAnD164rptLki1AG0AH4i88M">poster</a>
  </li>
  <li id="2018_ADHS_poster">
    <a href="https://www.cs.ox.ac.uk/conferences/ADHS18/"><em>IFAC Conference on Analysis and Design of Hybrid Systems</em></a>, July 2018.<br><a href="https://drive.google.com/open?id=1bS_-LxMFjS63uM6bireWFd8CrgERX-aj">poster</a>
  </li>
</ul>
~~~

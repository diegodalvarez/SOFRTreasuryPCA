# SOFR-Treasury PCA
Analysis of SOFR and Treasury Yield Curve through PCA

# Overview
There are a considerable amount of drivers for Treasury yields, although its considered that the main are economic and inflation related. While both factors work in tandem (usually), liquidity can be attributed as well (see footnotes) while the theory has less subscription in academia and industry. Given that in-theory the yield curve should trade arbitrage free which could be considered as a stronger condition of financial securities sharing the same stocahstic process (ie. same cashflow from Treasury) PCA can be easily applied. Given is commonplace within academia, industry, and the variuos other repos, the use of decomposing term structure-based securities (especially rates) tends to lend itself uself. 

The goal of this work is to analyze specific PCs through their economic intepretation of the Treasury Yield Curve and SOFR Curve. A consideration is that SOFR curve is more sensitive to monetary policy and thus an inflation outlook rather than other contributing factors to the Treasury Yield. Although a similar analysis can be completed within Breakeven rates (or really TIPS as a proxy) there has been a substantial amount of evidence linking breakevens to WTI and liquidity within the fixed income market. Breakevens in-theory should provide an expected inflation outlook since they match tenors between Treasuries and TIPS, but SOFR is a bit more intuitive for understanding current (somewhat nowcasted) inflation since the swap rate is SOFRRATE. 

# Background
First begin with Historical Treasury Yields and SOFR Swaps 
![image](https://github.com/diegodalvarez/SOFRTreasuryPCA/assets/48641554/07dd2e70-e6d5-403c-8a1f-b08a34b962f9)

There are various term structure shapes historically 
![image](https://github.com/diegodalvarez/SOFRTreasuryPCA/assets/48641554/ea0e6e9e-5d58-4117-b953-63ed59d5df8e)

Looking at the curves as of this publication
![image](https://github.com/diegodalvarez/SOFRTreasuryPCA/assets/48641554/61566392-0667-4d72-a6af-e6e1310cd5da)

# PCA Model
Decomposing the curves by 3 components 
![image](https://github.com/diegodalvarez/SOFRTreasuryPCA/assets/48641554/687d9962-f0ba-4657-ba64-f53e92ba0489)

Comparing the components by PC rather than curve
![image](https://github.com/diegodalvarez/SOFRTreasuryPCA/assets/48641554/fd549cb6-cc07-41ad-8e0d-cfff253fc859)

Looking at the spread
![image](https://github.com/diegodalvarez/SOFRTreasuryPCA/assets/48641554/4732ee18-ec47-4ce8-b4a2-b9d972c772b7)

The Distribution of spread
![image](https://github.com/diegodalvarez/SOFRTreasuryPCA/assets/48641554/f429e610-da51-4a15-9ad4-eb73cf1c6826)

30d Rolling Correlation between PCs
![image](https://github.com/diegodalvarez/SOFRTreasuryPCA/assets/48641554/78ccc824-afe0-4b9f-8105-1632b65f1ee9)

# Analysis & Interpration
With regards to spread and the correlation we can actually see the decoupling of curve changes (with respect to shift, slope, and convexity) from inflation. An ordinary economic thought-process would attribute this decoupling with difference in outlook to economic drivers. Economic-purests would suggest that the spreads are autoregressive given that inflation and economic drivers should move hand-in-hand, although the narrative has changed with the advent of unorthodox monetary policy (quantitative easing & tightening). Financial-practioners would most likely uphold the unorthodox monetary claim, but would also attest other factors are at play driving treasury yields. A lesser known driver would be economic/financial reflexivity proxied via liquidity which follows the addage "Markets will stay irrational longer than you can stay solvent".

As per the development of this model into a tradable signal there are two main schools of thought, although there's a glaring confounding error that will be brought up at the end. On one hand is the autoregressive crowd which would put positions on the spread tightening and thus hoping that the Treasury yields tighen up to the SOFR rate. Looking at the current curve the divergence doesn't come until later tenors possibly suggesting that profits may not materialize for years. There are a couple of interesting plays for reversion of the spread through 2nd and 3rd principal components which lead to duration neutral portfolios as well a use options as an exposure to convexity. In the other school of thought would be finding dislocations within markets. The decoupling of yields from inflation shown as the spread can be interpretated as mispricing of assets from a risk-to-reward standpoint. This could be easily exploited through some sort of risk budgeting program. 

# Footnotes
1. J. Benson Durham Nominal U.S. Treasuries Embed Liquidity Premiums, Too: An Affine Model of the Term Structure [link]([https://pages.github.com](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4086033#:~:text=Second%2C%20counter%2Dcyclicality%20of%20required,term%20premiums%2C%20not%20liquidity%20premiums.)https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4086033#:~:text=Second%2C%20counter%2Dcyclicality%20of%20required,term%20premiums%2C%20not%20liquidity%20premiums./)

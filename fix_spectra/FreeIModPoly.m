%% Copyright (C) 2015 Wright State University
%% Author: Daniel P. Foose
%% This file is part of FreeIModPoly.

%% FreeIModPoly is distributed under two licenses, the GNU General Public License
%% v3 and the MIT License. Which license you use is left to your discretion

%% GPL Statement:
%% FreeIModPoly is free software; you can redistribute it and/or modify it
%% under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 3 of the License, or (at
%% your option) any later version.
%%
%% FreeIModPoly is distributed in the hope that it will be useful, but
%% WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%% General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with Octave; see the file COPYING.  If not, see
%% <http://www.gnu.org/licenses/>.

%% MIT License Statement:
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
%% THE SOFTWARE.

%% FreeIModPoly: A free software implementation of the Vancouver Raman Algorithm
%% Please cite DOI: 10.1366/000370207782597003 and this project (see CITATION)
%% The author of this implementation is not associated with the authors of the
%% algorithm.
%%
%% Inputs:
%% spectrum should be a column vector containing the spectrum to be corrected
%% abscissa should contain the abscissa (x-axis) values for spectrum
%% polyOrder is the polynomial order of the OLS baseline fits
%% maxIt is the maximum number of iterations. If maxIt is set to zero, there
%%     is no limit.
%% threshold is the value for the error critera abs(DEVi - DEVi-1 / DEVi). The
%%     iteration stops when the error critera is less than this value.
%% This value must be between 0 and 1.
%%
%% Outputs:
%% baseline is the fitted baseline
%% corrected is the baseline-corrected spectrum
%% coefs is a vector containing the regression coefficients of the fit.
%% coefs(1,1) is the constant term, coefs(2,1) is the linear term, coefs(3,1) is
%%     the quadratic term, and so on.
%% i is the total number of iterations performed to acheive the fit
%% err is the error criterion abs(DEVi - DEVi-1 / DEVi) of the final iteration

function [baseline, corrected, coefs, i, err]=...
FreeIModPoly(spectrum, abscissa, polyOrder, maxIt, threshold)
    if (nargin < 5)
        threshold = 0.05;
    end
    
    if (nargin < 4)
        maxIt = 100;
    end
    
    if (nargin < 3)
        polyOrder = 5;
    end
        
    if (polyOrder < 1)
        exit('polyOrder must be an integer greater than 0');
    end
    
    if (threshold >= 1 || threshold <= 0)
        exit('threshold must be a value between 0 and 1');
    end
    
    if(size(spectrum, 1) ~= size(abscissa, 1))
        exit('spectrum and abscissa must have same size');
    end

    i = 0;
    noMaxIt = (maxIt == 0);
    coefs = polyfit(abscissa, spectrum, polyOrder);
    fit = polyval(coefs, abscissa);
    dev = CalcDev(spectrum, fit);
    prevDev = dev;

    nonPeakInd = NonPeakInd(spectrum, dev);
    newAbscissa = abscissa(nonPeakInd);

    prevFit = spectrum(nonPeakInd);
    err = threshold;

    complete = 0;
    while (complete == 0)
        %Polynomial fitting%
        coefs = polyfit(newAbscissa, prevFit, polyOrder);
        fit = polyval(coefs, newAbscissa);
        %Calcualte residuals and dev%
        dev = CalcDev(prevFit, fit);
        %error criterion%
        err = CalcErr(dev, prevDev);
        %Reconstruction of model input
        fit = fit + dev;
        %if a value in the previous fit is lower than this fit, take previous
        ind = find(prevFit < fit);
        fit(ind) = prevFit(ind);
        prevFit = fit;
        prevDev = dev;
        i = i + 1;
        complete = (err < threshold || ((noMaxIt ~= 0) && (i >= maxIt)));
    end
    baseline = polyval(coefs, abscissa);
    corrected = spectrum - baseline;
end
    
  function dev=CalcDev(spectrum, fit)
      residual = spectrum - fit;
      averageResidual = mean(residual);
      centered = residual - averageResidual;
      centered = centered .^ 2;
      dev = sqrt(sum(centered)/size(centered,1));
  end

  function ind=NonPeakInd(spectrum, dev)
      SUM = spectrum + dev;
      ind = find(spectrum <= SUM);
  end
  
  function err=CalcErr(dev, prevDev)
        err = abs( (dev - prevDev) / dev);
  end

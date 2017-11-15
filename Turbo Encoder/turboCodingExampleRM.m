clear all;
close all;
clc;
% This file contains examples for using Turbo coding of the link level simulator. First,
% checkout the link level simulator: https://wn-git.fe.hhi.de/oe313/LinkLevelSimulator.

% Give the path to link level simulator.
path_to_lls = fullfile('C:', 'Users', 'eldessoki', 'Desktop', 'git_dir', ...
                        'LinkLevelSimulator');

% Add the path to the link level simulator to MALTAB's search pathes
addpath(genpath(path_to_lls));

% Keep in mind: the Turbo coder is a special of a convolutional coder.

% To configure any coder, you have to collect the parameters in a struct, for instance
% "cc", short for channel coding.
% At first, we say that we want to use channel coding and the type should be 'turbo' (for
% Turbo coding)
cc.use              = 'turbo'; % 'conv', 'turbo'

% You can also use 'conv'. In fact, for decoding convolutional codes, you need the
% communications toolbox in MATLAB in order to make use of Viterbi decoding. Turbo codes
% are decoded by a self-provided C-file (MEX file) and there's no need for a toolbox.

% You can change the constraint length of the coder.
cc.constr_length    = 4; % constraint length of the coder (memory length + 1)

% Here, you set the generator and feedback polynomial in octal (not decimal!)
% representation.
cc.gen_poly         = [13 15]; % generator polynomial of the coder (octal value)
cc.feedb_poly       = 13; % feedback polynomial of the coder (octal value)

% The Turbo coder has an interleaver/scrambler unit placed before the second constituent
% encoder. 'intlvr_source' sets the source, where to have the interleaver indices as
% input. Either while constructing the channel coding object or while calling the encoding
% (step) function. In the first case, you have to know the bit length beforehand.
cc.intlvr_source    = 'constructor'; % interleaver source: 'constructor' or 'step'

% Determine the interleaver indices. This external function implements the 3GPP
% interleaver mapping. Note, that not all input bit sizes are allowed, see 3GPP 36.212
% section 5.1.3.2.3 and 36.213 section 7.1.7.2.1.
tbs = 128;
cc.intlvr_idc       = getLteInterleaverIdc(tbs);

% You can define the number of iterations in the Turbo decoding step.
cc.n_iterations     = 8; % number of Turbo decoding iterations

% We support several decoding algorithms. The used one is a SISO-MAP decoder. This
% algorithm works in the log domain for performance reasons. Here, we face the so called
% Jacobi logarithm:
%
%           log(exp(a) + exp(b)) = max(a, b) + log(1 + exp(-|a - b|)).
%
% The right hand side can be approximated in several ways. Here, you can specify one
% method. For instance, you can use only the max() term and forget about the log() term.
% This mode is named 'max_log_map'. In fact, it is not quite accurate. A good one is
% 'corr_log_map', in which we approximate the log function by an additional correction
% term. If you need the true formula, use 'true_log_map'. This mode needs more time for
% computations and has no convincing gain over 'corr_log_map' mode.
cc.decoder_type     = 'corr_log_map'; %'true_log_map'; % type of turbo decoder, 'log_map', 'max_log_map', ...
                                      % 'const_log_map', 'corr_log_map', 'true_log_map'

% Finally, we set that we don't want to have a CRC check. This implies that we run through
% all the iterations and don't terminate decoding early if we have no errors in uncoded
% bitstream.
cc.crc_check        = false;

% We are not interested in coded LLR output of Turbo decoder.
cc.app_port         = true;
% cc.app_port         = false;
                                      
% Now call constructors                                       
turbo_enc = CcTurboEncMex(cc);
turbo_dec = CcTurboDecMex(cc);

% Rate matcher
rm.use       = true;
rm.source    = 'step'; % tbs, code rate source: 'constructor' or 'step'
rm.tbs       = []; % + 24 CRC bits
rm.code_rate = 1/4;
% Call the constructor
h_rm = RmLteEnc(rm);
h_rdem = RmLteDec(rm);

% set random bitstream
rng('default');
s = randi([0 1], tbs, 1);


% call the encoding function of the turbo_enc object by using 'step'
s_enc = turbo_enc.step(s);

% Rate match
[s_enc_rm, rm_not_null] = h_rm.step(s_enc, length(s), rm.code_rate);


% Rate Dematch
s_enc_rdem = h_rdem.step(s_enc_rm, length(s), rm_not_null);

% For decoding a stream, it is assumed that we got LLRs as input. LLRs are probabilities
% that a given bit is 0 (denoted by values > 0) or 1 (denoted by values < 0). Because of
% this and the lack of any other processing step like symbol demodulation, the input
% stream must changed the sign.
[s_dec llr_out] = turbo_dec.step(-s_enc_rdem);
% [s_dec llr_out] = turbo_dec.step(-s_enc);
% [s_dec] = turbo_dec.step(-s_enc);


% count bit errors. Note, that there are some cases, where there are errors! Even if no
% noise is present. This is an effect of the algorithms used in the MEX file and is  no
% error of your implementation. Normally, these artifacts vanish if redundancy bits are
% adeded.
err = sum(xor(s, s_dec));

fprintf('There are %d errors.\n', err);



%% Testing the turboEncode and turboDecode functions 
%Repeat the same block of data 40 times and see whether errors are multiplied
%by 40 or no 


inputData= repmat(transpose(s),4,10);
[encData, rm_not_null,cc, rm,h_rm ] = turboEncode(inputData, 1/4,[13 15], 13, 4, 128 );
[hardOutput extrLLRrm ] = turboDecode(encData, 8, 512, rm_not_null,cc,rm,h_rm );
err = sum(sum(xor(inputData(3,129:256), hardOutput(3,129:256)))) % second block of third user
err = sum(sum(xor(inputData, hardOutput)))

                                   
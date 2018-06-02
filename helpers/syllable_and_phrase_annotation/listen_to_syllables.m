load lrb85315template.mat;
oldc=1;
p = audioplayer(templates.wavs(1).wav,48000);
segT = templates.wavs(1).segType;
while 1==1
    c = input('syl. #:');
    if c ~= oldc
        p = audioplayer(templates.wavs(c).wav,48000);
        segT = templates.wavs(c).segType;
        oldc = c;
    end
    play(p);
    disp(['segType = ' num2str(segT)]);
end
    
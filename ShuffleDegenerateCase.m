function iMapout = ShuffleDegenerateCase(iMapin)
      iMapout = iMapin;
      if (iMapin == 6)
      if (rand > 0.5)
        iMapout = 17;
      end
    end
    % in degenerate case 10 pick randomly 10 or 18
    if (iMapin == 11)
      if (rand > 0.5)
        iMapout = 18;
      end
    end
end

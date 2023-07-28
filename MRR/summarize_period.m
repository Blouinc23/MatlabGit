%Gets the summary for each of the given dates and returns it in a cell
%array.
function summary = summarize_period(dates, serial_number, verbose)
    arguments
        dates datetime; %Array of dates to find summary of
        serial_number double = 50; %MRR serial number to use
        verbose logical = true;%Whether to ouput runtime information
    end
    
    summary = cell(1, length(dates));%Cell array to return
    timer = tic;
    for d = 1:length(dates)%For each date
        date = dates(d);
        if verbose
            disp("Summarizing data for " + datestr(date) + "... (Date " + d + " of " + length(dates) + ")")
        toc(timer)
        end
        %Find the summary
        try
            day_summary = get_MRR_day_summary(date, serial_number, verbose);
        catch
            %Set to NaN if summary can't be found
            disp("Error, could not collect data for " + datestr(date))
            day_summary = NaN;
        end
        %Put summary into cell array
        summary{d} = day_summary;
    end
    if verbose
        toc(timer)
    end
end
    
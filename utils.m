
classdef utils
    methods(Static) 
        function a_to_b = arange(a, b)
            
            if ~isa(a, 'double') || ~isa(b, 'double') % || ~isa(a, 'int16') || ~isa(b, 'int16')
                fprintf('variables a or b should be integer (double).\n');
                disp(class(a))
                disp(class(b))
                return
            end
            a_to_b = [];
            for i = a:(b-1)
                a_to_b = [a_to_b, i];
            end

        end
        
%         function copy_specific_files_from_dir()
%         end
        
        % move specific filename including 'matching_world' from the target
        % directory to destination directory
        function move_specific_files_from_dir(target_dir, dest_dir, matching_word)
            if nargin ~= 3
               fprintf('move_specific_files_from_dir(<target_dir>, <dest_dir>, <regexp>\n');
               return;
            end
            
            file_source_list = dir(target_dir);
       
            for i = 1:length(file_source_list)
                target_filename = file_source_list(i).name;
                if length(target_filename) > length(matching_word) & length(strfind(target_filename, matching_word)) > 0
                    movefile(strcat(target_dir, '\', target_filename), dest_dir)
                end
            end
        end
        
%         function remove_specific_files_from_dir()
%         end
        
            
    end
end


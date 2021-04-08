% string
% https://kr.mathworks.com/help/matlab/matlab_prog/create-string-arrays.html

% logical operator
% https://kr.mathworks.com/help/matlab/matlab_prog/matlab-operators-and-special-characters.html

% regex
% https://kr.mathworks.com/help/matlab/ref/regexp.html

classdef string_utils
    methods(Static) 
        
%       test function
        function ave = average(x)
            ave = sum(x(:))/numel(x);
        end
        
        % make dir
        function mkdir_list(dir_list, parent_path)
            % dir_list = ['/c/Users/a', '/c/Users/b']
            % string_utils.mkdir_list(dir_list)
            % dir_list = ['a', 'b']
            % string_utils.mkdir_list(dir_list, /c/Users)
            if nargin > 1
                for elem = dir_list
                  mkdir(parent_path+"\"+elem)
                end
            else
                for elem = dir_list
                  mkdir(elem)
                end
            end
        end
        
        % get only child files
        % option 0; only files 1; only directories 2; both
        function child_list = get_child_file_list(parent_path, option)
%             [example]
%             parent_path = "C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\test_dir";
%             res1 = string_utils.get_child_file_list(parent_path)

            % default param for option
            if nargin == 1 
                option = 2;
            elseif nargin < 1 || nargin >2 % param integrity 
                fprintf('This function need 1 or 2 arguments!\n')
                return
            end
            
            childs = dir(parent_path);
            %disp(childs(0).name)
            dirFlags = [childs.isdir];
            % fprintf("dirFlags\n")
            disp(dirFlags)
            child_list = [];
            % fprintf("first length: %d\n", length(child_list))
            for i=1:length(childs)
                % fprintf("index: %d\n", i)
                if dirFlags(i) == 0  % the child is a file
                    if option==0 || option==2
                        %fprintf("when child is a file, childs.name : %s\n", childs(i).name)
                        child_list = [child_list, string(childs(i).name)]
                        
                    else 
                        continue
                    end
                    
                else % the child is a directory
                    if option ==1 || option==2 
                        %fprintf("when child is a directory, childs.name : %s\n", childs(i).name)
                        child_list = [child_list, string(childs(i).name)]
                    else
                        continue
                    end
                    
                end
               
            end
            
        end
        
        % 
        function result_str_list = apply_func_to_string(str_list, func)
            %
            % [example] 
            % check_FBB_str_on_list_lambda = @(x) check_FBB_str_on_list(x);
            % res2 = string_utils.apply_func_to_string(res1, check_FBB_str_on_list_lambda)
            %
%             function matchStrResult = check_FBB_str_on_list(input_str)
%             expression = strcat('\w*', 'FBB', '\w*')
%             fprintf("[!] in check_FBB_str_on_list, input_str,  %s\n", input_str)
%             matchStrResult = regexp(input_str,expression,'match')
%                 if length(matchStrResult)==1 
%                     fprintf("True")
%                     matchStrResult=1
%                 else
%                     fprintf("False")
%                     matchStrResult=0
%                 end
%             end

            fprintf("apply_func_to_string, taki %s\n", str_list)
            result_str_list = []
            for i=1:length(str_list)
                fprintf("[!] In apply_func_to_string(), str_list(i), %s\n", str_list(i))
                tmp_res = func(str_list(i))
                result_str_list = [result_str_list, tmp_res]
            end 
        end
        
        
        
    end
end



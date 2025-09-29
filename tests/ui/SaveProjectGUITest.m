classdef SaveProjectGUITest < matlab.uitest.TestCase
    %SAVEPROJECTGUITEST Automated UI tests for the save project dialog.

    properties
        Gui Utilities.saveProjectGUI
    end

    methods (TestClassSetup)
        function addRepoToPath(testCase)
            import matlab.unittest.fixtures.PathFixture
            testCase.applyFixture(PathFixture(pwd));
        end
    end

    methods (TestMethodSetup)
        function createDialog(testCase)
            testCase.Gui = Utilities.saveProjectGUI;
            testCase.addTeardown(@() testCase.destroyDialog());
        end
    end

    methods (TestMethodTeardown)
        function clearDialogHandle(testCase)
            testCase.Gui = [];
        end
    end

    methods (Access = private)
        function destroyDialog(testCase)
            if isempty(testCase.Gui)
                return;
            end

            if ~isempty(testCase.Gui.Figure) && isvalid(testCase.Gui.Figure)
                delete(testCase.Gui.Figure);
            end
        end
    end

    methods (Test)
        function showsExpectedDefaultState(testCase)
            testCase.verifyEqual(testCase.Gui.Figure.Name, 'Save Project?');
            testCase.verifyEqual(testCase.Gui.PRJresponse, '');
            testCase.verifyTrue(testCase.Gui.SavePlotsCheckbox.Value);
            testCase.verifyTrue(testCase.Gui.PLTresponse);
        end

        function selectingNoRecordsResponseAndClosesDialog(testCase)
            fig = testCase.Gui.Figure;
            testCase.press(testCase.Gui.NoButton);
            drawnow;

            testCase.verifyEqual(testCase.Gui.PRJresponse, 'No');
            testCase.verifyFalse(isvalid(fig));
        end

        function togglingCheckboxUpdatesState(testCase)
            testCase.choose(testCase.Gui.SavePlotsCheckbox, false);
            drawnow;

            testCase.verifyFalse(testCase.Gui.SavePlotsCheckbox.Value);
            testCase.verifyFalse(testCase.Gui.PLTresponse);
        end

        function selectingCancelLeavesResponseEmpty(testCase)
            testCase.press(testCase.Gui.CancelButton);
            drawnow;

            testCase.verifyEqual(testCase.Gui.PRJresponse, 'Cancel');
        end
    end
end

package nl.nn.testtool.test.webapp;

import java.util.Arrays;
import java.util.HashSet;
import java.util.List;

import lombok.Setter;
import nl.nn.testtool.Checkpoint;
import nl.nn.testtool.Report;
import nl.nn.testtool.Rerunner;
import nl.nn.testtool.SecurityContext;
import nl.nn.testtool.TestTool;
import nl.nn.testtool.run.ReportRunner;

public class SimpleRerunner implements Rerunner {
	@Setter TestTool testTool;

	@Override
	public String rerun(String correlationId, Report originalReport,
			SecurityContext securityContext, ReportRunner reportRunner) {
		if(! rerunSpecialReport(correlationId, originalReport, securityContext, reportRunner)) {
			rerunDefault(correlationId, originalReport, securityContext, reportRunner);
		}
		return null;
	}

	/**
	 * Rerun a report that we want to investigate in the ladybug-frontend Cypress tests.
	 * For some reports, we want to edit them during the tests such that they will succeed
	 * on rerun.
	 * 
	 * @param correlationId
	 * @param originalReport
	 * @param securityContext
	 * @param reportRunner
	 * @return
	 */
	private boolean rerunSpecialReport(String correlationId, Report originalReport,
			SecurityContext securityContext, ReportRunner reportRunner) {
		if(new HashSet<>(Arrays.asList("Simple report", "Another simple report")).contains(originalReport.getName())) {
			testTool.startpoint(correlationId, null, originalReport.getName(), "Hello Original World!");
			testTool.endpoint(correlationId, null, originalReport.getName(), "Goodbye Original World!");
			return true;
		}
		return false;
	}

	private void rerunDefault(String correlationId, Report originalReport,
			SecurityContext securityContext, ReportRunner reportRunner) {
		List<Checkpoint> checkpoints = originalReport.getCheckpoints();
		String name = checkpoints.get(0).getName();
		String message = checkpoints.get(0).getMessage();
		testTool.startpoint(correlationId, this.getClass().getName(), name, message);
		testTool.infopoint(correlationId, this.getClass().getName(), "PLEASE NOTE",
				"This report is generated by SimpleRerunner which wil only copy the first and last checkpoint from the"
				+ " original report and discard all otehr checkpoint and it doesn't run any business logic like a"
				+ " normal Rerunner should do!");
		name = checkpoints.get(checkpoints.size() - 1).getName();
		message = checkpoints.get(checkpoints.size() - 1).getMessage();
		testTool.endpoint(correlationId, this.getClass().getName(), name, message);
	}
}

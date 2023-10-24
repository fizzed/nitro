import org.slf4j.Logger;
import java.util.List;
import static java.util.Arrays.asList;
import java.nio.file.Path;
import java.util.function.Supplier;
import static java.util.stream.Collectors.toList;
import com.fizzed.blaze.Contexts;
import com.fizzed.blaze.system.Exec;
import static com.fizzed.blaze.Contexts.withBaseDir;
import static com.fizzed.blaze.Contexts.fail;
import com.fizzed.blaze.Systems;
import static com.fizzed.blaze.Systems.exec;
import com.fizzed.blaze.ssh.SshSession;
import static com.fizzed.blaze.SecureShells.sshConnect;
import static com.fizzed.blaze.SecureShells.sshExec;
import com.fizzed.buildx.*;

public class blaze {

    private final List<Target> targets = asList(
        // Linux riscv64
        new Target("linux", "riscv64")
            //.setHost("bmh-jjlauer-2")
            .setContainerImage("adoptopenjdk/centos6_build_image")
    );

    public void build_containers() throws Exception {
        new Buildx(targets)
            .execute((target, project) -> {
                if (project.hasContainer()) {
                    project.exec("setup/build-docker-container-action.sh", target.getContainerImage(), project.getContainerName(), target.getOs(), target.getArch()).run();
                }
            });
    }

    public void build_jdk() throws Exception {
        new Buildx(targets)
            .execute((target, project) -> {
                String buildScript = "setup/build-jdk-action.sh";

                //project.action(buildScript, target.getOs(), target.getArch(), "19+36").run();
                project.action(buildScript, target.getOs(), target.getArch(), "21-ga").run();

                // if we're running on a remote host, copy over artifacts
                if (target.getHost() != null) {
                    project.rsync("target/*.tar.gz", "target/").run();
                }
            });
    }
    
    public void clean() throws Exception {
        exec("sudo", "rm", "-Rf", "target").run();
    }

    public void tests() throws Exception {
        new Buildx(targets)
            .execute((target, project) -> {
                project.action("setup/test-project-action.sh").run();
            });
    }

}

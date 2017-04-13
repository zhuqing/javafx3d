/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package pkg3dmodel;

import com.interactivemesh.jfx.importer.x3d.X3dModelImporter;
import java.io.IOException;
import java.net.URL;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import javafx.application.Application;
import javafx.application.Platform;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.scene.DepthTest;
import javafx.scene.Group;
import javafx.scene.Node;
import javafx.scene.PerspectiveCamera;
import javafx.scene.Scene;
import javafx.scene.SceneAntialiasing;
import javafx.scene.SubScene;
import javafx.scene.control.Button;
import javafx.scene.input.MouseEvent;
import javafx.scene.input.ScrollEvent;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.StackPane;
import javafx.scene.layout.VBox;
import javafx.scene.shape.CullFace;
import javafx.scene.shape.DrawMode;
import javafx.scene.shape.MeshView;
import javafx.scene.shape.TriangleMesh;
import javafx.scene.transform.Rotate;
import javafx.scene.transform.Translate;
import javafx.stage.Stage;
import static pkg3dmodel.PickMesh3D.buildTriangleMesh;

/**
 *
 * @author zhuqing
 */
public class Main extends Application {

    private static final double CONTROL_MULTIPLIER = 0.1;
    private static final double SHIFT_MULTIPLIER = 10.0;
    private static final double MOUSE_SPEED = 0.1;
    private static final double ROTATION_SPEED = 2.0;
    private static final double TRACK_SPEED = 0.3;

    double mousePosX;
    double mousePosY;
    double mouseOldX;
    double mouseOldY;
    double mouseDeltaX;
    double mouseDeltaY;

    private final Rotate cameraXRotate = new Rotate(-20, 0, 0, 0, Rotate.X_AXIS);
    private final Rotate cameraYRotate = new Rotate(-20, 0, 0, 0, Rotate.Y_AXIS);
    private final Translate cameraPosition = new Translate(0, 0, -20);

    private PerspectiveCamera camera;

    private double scaleFactor = 1;
    private SubScene subScene;

    private Group groupRoot;
    private double dragStartX, dragStartY, dragStartRotateX, dragStartRotateY;

    private Group root;

    @Override
    public void start(Stage primaryStage) {

        BorderPane borderPane = new BorderPane();
        try {
            root = loadX3d();
//            root.getChildren().add(createNewGroup());
//            pane.getChildren().addAll(root);

            borderPane.setLeft(createButton());
            borderPane.setCenter(root);

        } catch (IOException ex) {
            Logger.getLogger(Main.class.getName()).log(Level.SEVERE, null, ex);
        }
        Scene scene = new Scene(borderPane, 800, 600);
        initMouseDrag(scene);

        primaryStage.setTitle("Hello World!");
        primaryStage.setScene(scene);
        primaryStage.show();
    }

    private VBox createButton() {
        VBox vbox = new VBox();
        vbox.setPrefWidth(60);
        Button button1 = new Button("皮肤");
        button1.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {
                hiddeAndShow(0);
            }
        });

        Button button2 = new Button("肌肉");
        button2.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {
                hiddeAndShow(1);
            }
        });

        Button button3 = new Button("骨骼");
        button3.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {
                hiddeAndShow(2);
            }
        });

        vbox.getChildren().addAll(button1, button2, button3);
        return vbox;
    }

    private void hiddeAndShow(int index) {
        //   Group groupRoot = (Group) root.getChildren().get(0);
        if (index >= groupRoot.getChildren().size()) {
            return;
        }
        for (int i = 0; i < groupRoot.getChildren().size(); i++) {
            if (!(groupRoot.getChildren().get(i) instanceof Group)) {
                continue;
            }
            if (i == index) {
                hidden((Group) groupRoot.getChildren().get(i), true);
            } else {
                hidden((Group) groupRoot.getChildren().get(i), false);
            }

        }
    }

    private void hidden(Group group, boolean viable) {
        if (group.getChildren().isEmpty()) {
            return;
        }

        for (Node node : group.getChildren()) {
            if (node instanceof MeshView) {
                hiddenOrShow((MeshView) node, viable);
            }

            if (node instanceof Group) {
                hidden((Group) node, viable);
            }
        }

    }

    private void registHandler(Group group) {
        if (group.getChildren().isEmpty()) {
            return;
        }

        for (Node node : group.getChildren()) {
            if (node instanceof MeshView) {
                MeshView meshView = (MeshView) node;
                meshView.setDrawMode(DrawMode.FILL);
                meshView.setCullFace(CullFace.NONE);
                meshView.setOnMouseEntered(new EventHandler<MouseEvent>() {
                    @Override
                    public void handle(MouseEvent event) {
                        if (event.getClickCount() == 1) {
                            System.err.println(node.getId());
                        }
                    }
                });

                meshView.setOnMouseClicked(new EventHandler<MouseEvent>() {
                    @Override
                    public void handle(MouseEvent event) {
                        if (event.getClickCount() == 1) {
                            System.err.println(node.getId());
                        }
                    }
                });

            }

            if (node instanceof Group) {
                registHandler((Group) node);
//                node.addEventFilter(MouseEvent.ANY, new EventHandler<MouseEvent>() {
//                    @Override
//                    public void handle(MouseEvent event) {
//                        if (event.getClickCount() == 1) {
//                            System.err.println(node.getId());
//                        }
//                    }
//                });
            }
        }
    }

    private void hiddenOrShow(MeshView meshView, boolean visable) {
        meshView.setVisible(visable);
    }

    private Group loadX3d() throws IOException {

        camera = new PerspectiveCamera(true);
        camera.getTransforms().addAll(cameraXRotate, cameraYRotate, cameraPosition);

        groupRoot = Importer3D.load("C:\\Users\\zhuqing.BJGOODWILL\\Documents\\NetBeansProjects\\3dModel\\src\\resources\\hands.3DS");
        groupRoot.getChildren().add(camera);
        registHandler(groupRoot);
        groupRoot.setDepthTest(DepthTest.ENABLE);
        subScene = new SubScene(groupRoot, 800, 600, true, SceneAntialiasing.BALANCED);
        subScene.setCamera(camera);

        // Map<String, Node> namedSGOs = x3dModel.getNamedNodes();
        //root.getChildren().add(subScene);
        Group group = new Group();
        group.getChildren().add(subScene);

        return group;
    }

    private void initMouseDrag(Scene scene) {
        scene.addEventFilter(MouseEvent.ANY, new EventHandler<MouseEvent>() {
            @Override
            public void handle(MouseEvent event) {

                if (event.getEventType() == MouseEvent.MOUSE_PRESSED) {
                    dragStartX = event.getSceneX();
                    dragStartY = event.getSceneY();
                    dragStartRotateX = cameraXRotate.getAngle();
                    dragStartRotateY = cameraYRotate.getAngle();
                } else if (event.getEventType() == MouseEvent.MOUSE_DRAGGED) {
                    double xDelta = event.getSceneX() - dragStartX;
                    double yDelta = event.getSceneY() - dragStartY;
                    cameraXRotate.setAngle(dragStartRotateX - (yDelta * 0.3));
                    cameraYRotate.setAngle(dragStartRotateY + (xDelta * 0.3));
                }

            }
        });

        scene.setOnScroll(new EventHandler<ScrollEvent>() {
            @Override
            public void handle(ScrollEvent event) {
                double z = cameraPosition.getZ() - (event.getDeltaY() * 0.1 * scaleFactor);
                z = Math.min(z, 0);
                cameraPosition.setZ(z);
            }
        });

    }

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        launch(args);
    }

    private Group createNewGroup() {
        TriangleMesh triangleMesh = buildTriangleMesh(12, 12, 10);

        MeshView meshView = new MeshView(triangleMesh);
        meshView.setOnMouseClicked(new EventHandler<MouseEvent>() {
            @Override
            public void handle(MouseEvent event) {
                if (event.getClickCount() == 1) {
                    System.err.println("===============");
                }
            }
        });
        return new Group(meshView);
    }

}
